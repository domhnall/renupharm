#!/bin/sh

###############################################################################
# This script checks one or all existing Let's Encrypt SSL certificate(s) for
# expiration, renews it/them if necessary and optionally restarts webserver
# (configurable option, see below).
# This script does NOT mess with you Nginx/Apache config files, they remain untouched
# (there is no need to modify them, since symlinks in /etc/letsencrypt/live directories
# always point to the most recent certificate).
# 
# Let's Encrypt certificates are valid for 3 monts, so we should
# renew them approx. every 2 months to avoid near-expiry-date problems.
#
# USAGE:
#  -h or --help : Help message
#  --renew-all  : Check all LE certificates and renew them if necessary.
#                 Before you run it with this option, check configuration
#                 block below to be sure that you have correct paths,
#                 expiration limit and email settings.
#  CERT_NAME    : Check specific certificate and renew it if necessary.
#                 Script will search for a renewal configuration file
#                 in /etc/letsencrypt/renewal/CERT_NAME.conf and extract
#                 list of domains that are included in the certificate.
#                 Before you run this command, check that these files exist:
#                 /etc/letsencrypt/renewal/CERT_NAME.conf
#                 /etc/letsencrypt/live/CERT_NAME/cert.pem
#                 If these files do not exist an error message will be shown.
#
# In case at least one certificate was renewed during script execution,
# a $CMD_SRV_RESTART command will be executed (useful for reloading webserver,
# or any other services that use LE certificates (see configuration block).
# If renewal of a certificate fails, an alert email will be sent.
#
# LE client logs all errors automatically to this file:
# /var/log/letsencrypt/letsencrypt.log
#
# Return codes: if used with --renew-all, then script always returns 0,
# because we can't determine whether renewal of individual certificates caused
# any errors. If used without --renew-all option, returns 0 if certificated
# does not need to be renewed or if certificate was successfully renewed.
# Returns 1 on errors (certificate file not found, renewal failed).
#
# Source loosely based on:
# http://eblog.damia.net/2015/12/03/lets-encrypt-automation-on-debian/
###############################################################################
#
# Update history:
#
# 03.12.2015 v1.0
# The very first version. Does not support multiple-domain certificates.
#
# 05.12.2015 v1.1
# Support for multiple-domain certificates. If used as script_name <CERT_NAME>,
# takes domain list from /etc/letsencrypt/renewal/CERT_NAME.conf file
#
# 08.12.2015 v1.2
# No bug fixing, typo corrections and small code improvements.
#
# 25.12.2015 v1.3
# Removed superfluous "sync" from CMD_SRV_RESTART. Thanks to allo and TCM from Let's Encrypt forums.
#
# 16.04.2016
# Updated setting to be appropriate for cerealquotes.com
#
# 22.08.2018
# Updated setting to be appropriate for renupharm.ie

###############################################################################
SCRIPT_DESCRIPTION="Check and renew (if necessary) SSL certificate(s) from Let's Encrypt"
SCRIPT_AUTHOR="Acetylator"
SCRIPT_VERSION="1.3"
SCRIPT_DATE="25.12.2015"
SCRIPT_NAME=$(basename "$0")
###############################################################################

# This line MUST be present in all scripts executed by cron!
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Before we start, set $CERT_NAME variable from the first parameter
CERT_NAME="$1"

###############################################################################
# CONFIGURATION START
###############################################################################

# Remaining days to expire before try renew.
# Let's Encrypt certificates expire in 90 days (on 12/2015).
# Currently, Let's Encrypt recommends renewal after 60 days.
# In future, this value may become even smaller.
# We renew our certificate when it expires in 30 days,
# which gives us plenty of time to react in case something goes wrong.
DAYS_REMAINING=30;

# Originating email, which will be used in FROM: field for email alerts.
# In case you use name, use this format: "johndoe@domain.tld (John Doe)".
EMAIL_ALERT_ADDRESS_FROM="server@renupharm.ie (Server)"

# Destination email, to which an alert email will be sent,
# in case that certificate renewal fails.
EMAIL_ALERT_ADDRESS_TO="dev@renupharm.ie"

# Subject of alert email. We can use $CERT_NAME variable, it is already set.
EMAIL_ALERT_SUBJ="WARNING: Let's Encrypt SSL certificate renewal for ${CERT_NAME} failed!"

# Full path to template file, containing email body.
# There is NO variable evaluation/substitution, the file will be sent as-is.
EMAIL_ALERT_BODY_FILE="/opt/cert_renewal/alert_email.txt"

# This command restarts or reloads our webserver, and
# eventually all other servers and services that depend on
# our certificates (for example, mail server, etc.)
# There is no need to use absolute paths (we have set $PATH variable at the beginning).
# To use multiple commands, use "cmd1; cmd2; cmd 3"
# There is no need to restart following services, it is sufficient to reload them.
CMD_SRV_RESTART="service nginx reload"

# -----------------------------------------------------------------------------
# CONSTANTS
# Check that all paths are correct.
# Other than that, you don't need to change anything here.
# -----------------------------------------------------------------------------

# Path to letsencrypt-auto script.
# On our server, it is located in /opt/letsencrypt/letsencrypt-auto
LEBIN="/opt/letsencrypt/letsencrypt-auto"

# Config file that is Let's Encrypt should use.
# Specify it explicitly to avoid any possible confusion
LECFG="/opt/cert_renewal/cli.ini"

# Live directory, which contains .pem certificates.
# Typically it is /etc/letsencrypt/live. Do not use trailing slash.
LELIVE="/etc/letsencrypt/live"

# Renewal directory, which contains renewal configs for all certificates.
# Typically it is /etc/letsencrypt/renewal. Do not use trailing slash.
LERENEWAL="/etc/letsencrypt/renewal"

# Name of the option to check all certificates and renew them,
# if necessary.
OPT_RENEW_ALL="--renew-all"
# This option is used when we renewing all certificates and we don't
# want to restart our webserver after each renewal.
# If this option is used, no initial info will be displayed.
# This option is used only internally and is not intended to
# be used by a human user.
OPT_NO_SRV_RESTART="--no-srv-restart"

###############################################################################
# CONFIGURATION END
# Do not edit beyond this line.
###############################################################################

# -----------------------------------------------------------------------------
# This function examines .pem certificate file (passed as parameter $1) and
# returns in how many days will the certificate expire.
# Result value is placed in $DAYS_EXP global variable.
get_days_exp() {
  local d1=$(date -d "`openssl x509 -in $1 -text -noout|grep "Not After"|cut -c 25-`" +%s)
  local d2=$(date -d "now" +%s)
  # Return result in global variable
  DAYS_EXP=$(echo \( $d1 - $d2 \) / 86400 |bc)
}
# -----------------------------------------------------------------------------

# Show help if there are are no arguments specified or help is explicitly requested
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "${SCRIPT_DESCRIPTION}"
  echo "Author: ${SCRIPT_AUTHOR}  Version: ${SCRIPT_VERSION}  Last modified: ${SCRIPT_DATE}"
  echo "Usage: ${SCRIPT_NAME} [CERT_NAME|--renew-all] [-h]"
  echo "CERT_NAME must be an existing .conf file in ${LERENEWAL}/ directory."
  echo "For example, using domain.tld as CERT_NAME will use ${LERENEWAL}/domain.tld.conf file to get domain list."
  echo "Also, ${LELIVE}/live/CERT_NAME/cert.pem certificated must exist."
  echo "In case of errors, check /var/log/letsencrypt/letsencrypt.log"
  # If there are no parameters, display error message.
  if [ $# -eq 0 ]; then
    echo ""
    echo "ERROR:   Certificate not specified. To check and renew all certificates, use ${OPT_RENEW_ALL} option."
  fi
  exit 1;
fi;

# -----------------------------------------------------------------------------
# Are we called with parameter --renew-all? In this case
# call our script recursively with each certificate found in $LELIVE
# as $1 parameter.
if [ "$1" = "${OPT_RENEW_ALL}" ]; then
  echo "INFO:    All certificates will be now checked and renewed, if necessary."
  # Set $NEED_SRV_RESTART to 0 as initial value.
  NEED_SRV_RESTART=0
  # Check and renew every individual certificate, running ourselves recursively.
  # Server will be restarted only after we renew all certificates.
  # We can use $CERT_NAME here, despite we have already defined it.
  # Since we use $OPT_RENEW_ALL, we are not going to use previously set value.
  for CERT_NAME in $(ls -1 "${LELIVE}"); do
    $0 "${CERT_NAME}" ${OPT_NO_SRV_RESTART}
    # Check last code. If it is 1, it means that certificate was renewed.
    # In this case we set $NEED_SRV_RESTART to 1.
    if [ "$?" -eq 1 ]; then NEED_SRV_RESTART=1; fi
  done
  # After we are finished, restart server, if needed
  if [ "$NEED_SRV_RESTART" -eq 1 ]; then 
    eval $CMD_SRV_RESTART
  fi
  # All done, exit now. Here, we always use code 0, because we can't
  # tell whether there were any errors during execution.
  exit 0;
fi;
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# This block checks individual certificate and renews it, if necessary
#
# Exit codes are used as following:
# * If we use $OPT_NO_SRV_RESTART, it means that we were recursively called
#   from above (see $0 ....) and we use exit code to tell caller script whether
#   certificate has changed (e.g. was renewed).
#   - Code 1 indicates that certificate was renewed and server(s) must be restarted.
#   - Code 0 indicates that no renewal was done (any reason - file not found,
#     renewal not necessary, renewal failure).
# * If we do NOT use $OPT_NO_SRV_RESTART option, it is vice versa:
#   - Code 0 indicates success (certificate was renewed or renewal was not needed),
#   - Code 1 indicates failure (certificate file not found or renewal failed).
#
# -----------------------------------------------------------------------------

# OK, certificate is specified in the parameter,
# so set necessary variables first. $CERT_NAME is already set now.
#
# This is certificate file, located in /live directory
# We use it to check when does the certificate expire.
CERT_FILE="${LELIVE}/${CERT_NAME}/cert.pem"
# This is renewal configuration file, containing list of all domains for current $CERT_NAME
CERT_CONF="${LERENEWAL}/${CERT_NAME}.conf"

# This is not very interesting info, so let's disable it.
#echo "INFO:    Processing certificate for $1, located in ${CERT_FILE}"

# Check whether certificate file (.pem) exists
if [ ! -f ${CERT_FILE} ]; then
  echo "ERROR:   Certificate file ${CERT_FILE} not found."
  # Set exit code, see comments above
  if [ "$2" = "${OPT_NO_SRV_RESTART}" ]; then exit 0; else exit 1; fi
fi

# Check whether renewal configuration file (.conf) exists
if [ ! -f ${CERT_CONF} ]; then
  echo "ERROR:   Renewal configuration file ${CERT_CONF} not found."
  # Set exit code, see comments above
  if [ "$2" = "${OPT_NO_SRV_RESTART}" ]; then exit 0; else exit 1; fi
fi

# Determine in how many days will the certificate expire.
# Result will be placed in $DAYS_EXP
get_days_exp "${CERT_FILE}"
echo -n "INFO:    Certificate for ${CERT_NAME} will expire in ${DAYS_EXP} days. "
# Save $DAYS_EXP value for later use
OLD_DAYS_EXP=$DAYS_EXP

# Check if we need to renew it
if [ "$DAYS_EXP" -gt "$DAYS_REMAINING" ]; then
  echo "Renewal is not necessary."
  # Set exit code, see comments above
  if [ "$2" = "${OPT_NO_SRV_RESTART}" ]; then
    exit 0
  else
    exit 1
  fi
else
  echo "Certificate is nearing expiry date! Trying to renew..."
  echo ""
  # Now we need to get domain list from the $CERT_CONF file.
  # It is very important that we use the same domain list, for which the original
  # certificate (located in .pem file) was issued. LE saves this list into $CERT_CONF file.
  # If we do not use the same domain list, LE will issue a new certificate,
  # which might create an entry like domain.tld-0001 in your configuration,
  # which will mess up our certificates!
  # We need to read this file and get this domain list, so we can supply it to LE client.
  # There is a line "domains = xxxxx" there, for example:
  # domains = domain.tld, www.domain.tld
  # OR
  # domains = domain.tld,
  #
  # Note trailing comma! We have to read this value from the file, check whether
  # there is a trailing comma there and remove it, if found.
  # 
  # Read domains from existing certificate into $DOMAINS
  DOMAINS=$(openssl x509 -in ${CERT_FILE} -text | awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | tr -d "DNS:")
  # Determine last character
  last_char=$(echo "${DOMAINS}" | awk '{print substr($0,length,1)}')
  # If last character is comma, then delete it from $DOMAINS
  if [ "${last_char}" = "," ]; then
    DOMAINS=$(echo "${DOMAINS}" |awk '{print substr($0, 1, length-1)}')
  fi
  # Now $DOMAINS contains list of domains that we are going to supply to LE client.
  # OK, we have prepared everything. Now try to renew certificates for $DOMAINS via LE Client.
  ${LEBIN} certonly --renew-by-default --config "${LECFG}" --domains "${DOMAINS}"
  # After renewal, try to determine when does the new certificate expire.
  # If renewal went OK, new value of $DAYS_EXP should be greater than $OLD_DAYS_EXP.
  get_days_exp "${CERT_FILE}"
  # Is $DAYS_EXP now less than or equal to $OLD_DAYS_EXP? If not, then renewal has failed.
  # If renewal went OK, then $DAYS_EXP must be greater than $OLD_DAYS_EXP.
  if [ "$DAYS_EXP" -le "$OLD_DAYS_EXP" ]; then
    echo "ERROR:   Certificate renewal failed. An e-mail alert was sent to ${EMAIL_ALERT_ADDRESS_TO}."
    # Send alert email
    cat "${EMAIL_ALERT_BODY_FILE}" | mail -aFrom:"${EMAIL_ALERT_ADDRESS_FROM}" -s "${EMAIL_ALERT_SUBJ}" ${EMAIL_ALERT_ADDRESS_TO}
    # Set exit code, see comments above
    if [ "$2" = "${OPT_NO_SRV_RESTART}" ]; then exit 0; else exit 1; fi;
  else
    echo "SUCCESS: Certificate was successfully renewed."
    # After successful renewal, restart server,
    # but only if option $OPT_NO_SRV_RESTART is not present
    # This option is normally set if we were executed first with --renew-all parameter.
    if [ "$2" = "${OPT_NO_SRV_RESTART}" ]; then
      # If $OPT_NO_SRV_RESTART is present, then exit with code 1.
      # This will indicate calling script that certificate was renewed and
      # server(s) must be restarted
      exit 1
    else
      echo ""
      echo "INFO:    Restarting server."
      echo ""
      eval $CMD_SRV_RESTART
      # We can return 0 now, because $OPT_NO_SRV_RESTART is not present, so in this case
      # 0 means success.
      exit 0;
    fi;
  fi;
fi;

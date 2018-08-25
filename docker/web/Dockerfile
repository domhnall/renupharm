# Set nginx base image
FROM nginx

# File Author / Maintainer
MAINTAINER Domhnall Murphy

# Install required packages
RUN apt-get -y update && apt-get install -y git cron bc
#software-properties-common

# Get certbot
#RUN add-apt-repository ppa:certbot/certbot && apt-get update && apt-get install python-certbot-nginx

# Get letsencrypt
WORKDIR /opt
RUN git clone https://github.com/letsencrypt/letsencrypt
#WORKDIR letsencrypt
#RUN TERM=xterm ./letsencrypt-auto certonly --test-cert --webroot -w /usr/share/nginx/html -d cerealquotes.com -d www.cerealquotes.com

RUN mkdir -p /etc/letsencrypt

# Set up automated LetsEncrypt cert renewal
RUN mkdir -p /opt/cert_renewal/
COPY cert_renewal/ /opt/cert_renewal
ADD cert_renewal/crontab /etc/cron.d/letsencrypt-cron
RUN chmod 0644 /etc/cron.d/letsencrypt-cron
RUN touch /var/log/cron.letsencrypt.log

# Fixing a bug in pam login https://stackoverflow.com/questions/43323754/cannot-make-remove-an-entry-for-the-specified-session-cron
RUN sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron

RUN cron

ARG nginx_env
# Copy custom configuration file from the current directory
COPY nginx.$nginx_env.conf /etc/nginx/nginx.conf

# Set up initial basic HTTP auth
COPY htpasswd /etc/nginx/.htpasswd

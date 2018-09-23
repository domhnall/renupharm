# Troubleshooting

## Set up SSL on first time environment set up

Deploying to production for the first time will require an SSL cert to be
in place. I haven't automated this as I am hoping it will be an infrequent
occurrence:

* Update the nginx config to remove the SSL block (i.e. just have server
  listening on port 80).
* Rebuild the nginx image (as described above) and push this as the
  latest image.
* Deploy to ECS: Nginx should now start listening solely on port 80.
* Run certbot-auto from the commandline which should install the certs

  > cd ~/letsencrypt
  > ./certbot-auto certonly -d renupharm.ie -d www.renupharm.ie

* With certs in place, rebuild nginx container with SSL block in place
* Redeploy to ECS

# RenuPharm

RenuPharm is an online marketplace facilitating the transaction of no-usage medications between Irish pharmacies.

## Setting up environment for development

Install node
Install yarn

> curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
> echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
> sudo apt-get update && sudo apt-get install yarn

Run webpack dev server

> bin/webpack-dev-server

Run rails server

> bin/rails s


## Local docker setup

> NGINX_ENV=development docker-compose build
> docker-compose up
> docker-compose run app bin/rake renupharm:setup_dev

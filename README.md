RenuPharm

# Setting up environment for development

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



## Deployment

You will need to install the AWS CLI and the separate ECS CLI:

> pip install awscli --upgrade --user
> sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
> sudo chmod +x /usr/local/bin/ecs-cli

You will need to authenticate your docker client with ECS

> aws ecr get-login --no-include-email

Then paste the generated login command to your local terminal.
Now configure the ECS CLI to allow deployments:

> ecs-cli configure --cluster renupharm-new --region eu-west-1 --default-launch-type EC2 --config-name renupharm-new
> ecs-cli configure profile --profile-name domhnall-renupharm --access-key <AWS_ACCESS_KEY_ID> --secret-key <AWS_SECRET_ACCESS_KEY>

The credentials are taken from the account under which you intend to use to connect to AWS.
We want to create a cluster to deploy our containers to:

> ecs-cli up --keypair domhnall-renupharm --capability-iam --size 1 --instance-type t2.small --cluster-config renupharm-new

## Deploying new nginx image

> NGINX_ENV=production docker-compose build web
> docker tag renupharm_web:latest 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm-nginx:latest
> docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm-nginx:latest

### Each deployment

Generate a docker image, tag it and push to the AWS registry

> docker-compose build app
> docker tag renupharm_app 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
> docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm

Run docker-compose up on the ECS cluster

> ecs-cli compose --cluster-config renupharm-new --file docker-compose.production.yml up
> ecs-cli ps


## SSH on to AWS
> ssh -i ~/keys/domhnall-renupharm.pem ec2-user@renupharm.ie


## Running tests
> docker-compose run -e "RAILS_ENV=test" app bin/rake all_tests


## Debugging

This is supported by the following settings in docker-compose.yml

```
  app:
    tty: true
    stdin_open: true
```

Place your `byebug` statement where you want to break in then attach to
the running container as

> docker attach renupharm_app_1




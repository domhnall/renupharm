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

> docker-compose -f docker/docker-compose.yml run app_1 bin/rake renupharm:setup_dev



## Deployment

You will need to install the AWS CLI and the separate ECS CLI:

> pip install awscli --upgrade --user
> sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
> sudo chmod +x /usr/local/bin/ecs-cli

You will need to authenticate your docker client with ECS

> aws ecr get-login --no-include-email

Then paste the generated login command to your local terminal.
Now configure the ECS CLI to allow deployments:

> ecs-cli configure --cluster renupharm --region eu-west-1 --default-launch-type EC2 --config-name renupharm
> ecs-cli configure profile --profile-name domhnall-renupharm --access-key <AWS_ACCESS_KEY_ID> --secret-key <AWS_SECRET_ACCESS_KEY>

The credentials are taken from the account under which you intend to use to connect to AWS.
We want to create a cluster to deploy our containers to:

> ecs-cli up --keypair domhnall-renupharm --capability-iam --size 1 --instance-type t2.micro --cluster-config renupharm

## Deploying new nginx image

> docker-compose -f docker/docker-compose.yml build
> docker tag renupharm_web:latest 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm-nginx:latest
> docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm-nginx:latest

### Each deployment

Generate a docker image, tag it and push to the AWS registry

> docker-compose -f docker/docker-compose.yml build
> docker tag docker_app_1 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
> docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm

Run docker-compose up on the ECS cluster

> ecs-cli compose --cluster-config renupharm --file docker/docker-compose.production.yml up
> ecs-cli ps


## SSH on to AWS
> ssh -i ~/keys/domhnall-renupharm.pem ec2-user@renupharm.ie

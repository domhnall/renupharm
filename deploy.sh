#!/bin/bash
if [ $# -ne 1 ]; then
  echo "You must supply the tag or branch name to be deployed"
  exit 1
fi

# Ensure we have added the renupharm key to the key-chain
ssh-add ~/.ssh/domhnall-renupharm

PROJ_DIR=`pwd`

# Authenticate ECR with docker
eval "$(aws ecr get-login --no-include-email)"

# Clone repo and checkout branch/tag to build
cd /tmp
sudo rm -rf renupharm
git clone git@bitbucket.org:domhnall_murphy/renupharm.git
cd renupharm
git checkout $1
cp ${PROJ_DIR}/config/master.key ./config/master.key

# Run full test suite
if docker-compose run -e "RAILS_ENV=test" app bundle exec rake all_tests; then
  echo "TEST SUITE PASSED. PROCEEDING WITH DEPLOY"

  # Build and tag app image, push image to ECR
  docker-compose build app
  docker tag renupharm_app 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
  docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm

  # Deploy the updated image
  # As image version is not specified in task definition --force-new-deployment will
  # pull the latest version of the image we have just uploaded
  aws ecs update-service --cluster renupharm-new --service renupharm-service --force-new-deployment

  # Any changes to the docker-compose.production.yml need to be uploaded to create a new task.
  # This new task will then be used to create a new service
  # This is not automated yet, so will need to walk through these update steps manually on AWS console
  #
  # ecs-cli compose --cluster-config renupharm-new --file docker-compose.production.yml up

  # Run any outstanding migrations
  APP_CONTAINER=`ssh ec2-user@renupharm.ie "docker ps --format \"{{.Names}}\" | grep app1"`
  ssh ec2-user@renupharm.ie "docker exec ${APP_CONTAINER} bin/rake db:migrate"

  # Rebuild indexes
  ssh ec2-user@renupharm.ie "docker exec ${APP_CONTAINER} bin/rake sunspot:reindex"

  # Update the crontab
  scp config/renupharm.crontab ec2-user@renupharm.ie:/tmp
  ssh ec2-user@renupharm.ie "(crontab -l 2>/dev/null; cat /tmp/renupharm.crontab) | crontab -"
else
  echo "TEST SUITE FAILED. ABORTING DEPLOY" && exit 1
fi

#!/bin/bash
if [ $# -ne 1 ]; then
  echo "You must supply the tag or branch name to be deployed"
  exit 1
fi

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
  ecs-cli compose --cluster-config renupharm-new --file docker-compose.production.yml up

  # Run any outstanding migrations
  APP_CONTAINER=`ssh ec2-user@renupharm.ie "docker ps --format \"{{.Names}}\" | grep app1"`
  ssh ec2-user@renupharm.ie "docker exec ${APP_CONTAINER} bundle exec rake db:migrate"

  # Update the crontab
  scp -i ~/keys/domhnall-renupharm.pem config/renupharm.crontab ec2-user@renupharm.ie:/tmp
  ssh -i ~/keys/domhnall-renupharm.pem ec2-user@renupharm.ie "(crontab -l 2>/dev/null; cat /tmp/renupharm.crontab) | crontab -"
else
  echo "TEST SUITE FAILED. ABORTING DEPLOY" && exit 1
fi

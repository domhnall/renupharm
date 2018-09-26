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
else
  echo "TEST SUITE FAILED. ABORTING DEPLOY" && exit 1
fi

#!/bin/bash
if [ $# -ne 1 ]; then
  echo "You must supply the tag or branch name to be deployed"
  exit 1
fi
BRANCH=${1}

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
git checkout $BRANCH
cp ${PROJ_DIR}/config/master.key ./config/master.key

# Run full test suite
if true; then #docker-compose run -e "RAILS_ENV=test" app bundle exec rake all_tests; then
  echo "TEST SUITE PASSED. PROCEEDING WITH DEPLOY"

  # Build and tag app image, push image to ECR
  docker-compose build app
  docker tag renupharm_app 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
  docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm

  # Deploy the updated image
  ssh -i ~/keys/domhnallmurphy.pem ubuntu@domhnallmurphy.com "/home/ubuntu/app/renupharm/deploy/remote.sh ${BRANCH}"

  # Run any outstanding migrations
  APP_CONTAINER=`ssh ubuntu@domhnallmurphy.com "docker ps --format \"{{.Names}}\" | grep renupharm_app_1"`
  ssh ubuntu@domhnallmurphy.com "docker exec ${APP_CONTAINER} bin/rake db:migrate"

  # Rebuild indexes
  ssh ubuntu@domhnallmurphy.com "docker exec ${APP_CONTAINER} bin/rake sunspot:reindex"

  # Update the crontab
  scp config/renupharm.crontab ubuntu@domhnallmurphy.com:/tmp
  ssh ubuntu@domhnallmurphy.com "(cat /tmp/renupharm.crontab) | crontab -"
else
  echo "TEST SUITE FAILED. ABORTING DEPLOY" && exit 1
fi

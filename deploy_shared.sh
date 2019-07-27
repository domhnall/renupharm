#!/bin/sh
BRANCH=${1}
ssh -i ~/keys/domhnallmurphy.pem ec2-user@domhnallmurphy.com "echo \"#!/bin/sh
BRANCH=${1}
cd /home/ec2-user/app/renupharm
git checkout master
git pull
git checkout ${BRANCH}
git pull origin ${BRANCH}
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml up\" > /tmp/remote.sh && /tmp/remote.sh"

#!/bin/sh
BRANCH=${1}
RELEASE_DIR=`date +%Y%m%d%H%M%S`

mkdir /home/ubuntu/app/renupharm_releases/${RELEASE_DIR}
cd /home/ubuntu/app/renupharm_releases/${RELEASE_DIR}
git clone git@bitbucket.org:domhnall_murphy/renupharm.git
cd renupharm
git checkout master
git pull
git checkout ${BRANCH}
git pull origin ${BRANCH}
ln -sfn /home/ubuntu/app/renupharm_releases/${RELEASE_DIR}/renupharm /home/ubuntu/app/renupharm
cd /home/ubuntu/app/renupharm
docker-compose -f docker-compose.production.yml up -d
cd /home/ubuntu/app/renupharm_releases
ls | head -$(($(ls | wc -l)-3)) | xargs rm -rf

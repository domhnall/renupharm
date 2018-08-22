#!/bin/sh
BRANCH=${1}
cd /home/ec2-user/nginx-docker
git checkout master
git pull
git checkout ${BRANCH}
git pull origin ${BRANCH}
docker build -t nginx-docker-img .
docker stop nginx-docker-cont
docker rm nginx-docker-cont
docker run -d -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt --restart=always --name nginx-docker-cont --link domhnallmurphy_node_1_1:domhnallmurphy_1 --link domhnallmurphy_node_2_1:domhnallmurphy_2 --link cerealquotes_node_1_1:cerealquotes_1 --link cerealquotes_node_2_1:cerealquotes_2 nginx-docker-img

docker-compose build app
docker tag renupharm_app 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
docker push 348231524911.dkr.ecr.eu-west-1.amazonaws.com/renupharm
ecs-cli compose --cluster-config renupharm --file docker-compose.production.yml up

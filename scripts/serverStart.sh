#!/bin/sh

DOCKER_CONTAINER_NAME=$1

DOCKER_CONTAINER_ID=$(docker ps -q -f "name=$DOCKER_CONTAINER_NAME")

if [ $DOCKER_CONTAINER_ID == -z ];
  then
    exit 1
fi

cd $(dirname $0)
cd ..

./gradlew clean $DOCKER_CONTAINER_NAME:build

echo "> 파일 전송 시작"
echo "> 컨테이너 ID : $DOCKER_CONTAINER_ID"
echo "> 컨테이너 Name : $DOCKER_CONTAINER_NAME"

JAR_FILE_NAME=$DOCKER_CONTAINER_NAME-0.0.1-SNAPSHOT.jar
DEPLOY_SH_FILE_NAME=deploy.sh

docker cp $DOCKER_CONTAINER_NAME/build/libs/$JAR_FILE_NAME $DOCKER_CONTAINER_ID:/home
docker cp scripts/$DEPLOY_SH_FILE_NAME $DOCKER_CONTAINER_ID:/home

#docker exec -d $DOCKER_CONTAINER_ID fuser -k 8080/tcp

#docker exec -d $DOCKER_CONTAINER_ID java -jar home/server1-0.0.1-SNAPSHOT.jar
docker exec -e JAR_FILE_NAME="home/$JAR_FILE_NAME" $DOCKER_CONTAINER_ID sh home/$DEPLOY_SH_FILE_NAME

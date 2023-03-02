#!/bin/sh

use_port1() {
  START_PORT=8080
  KILL_PORT=8081

  START_PROFILE="port-1"
}
use_port2() {
  START_PORT=8081
  KILL_PORT=8080

  START_PROFILE="port-2"
}
print_current_port_info() {
  echo "> 현재 실행 중 Port $KILL_PORT"
}
health_check() {
  for count in $(seq 1 50)
    do
      HEALTH_CHECK=$(curl -s $1)

      if [ $(echo $HEALTH_CHECK | grep 'health' | wc -l) -gt 0 ]; then
        echo "> Health Check 성공"
        break
      else
        echo "> Health Check의 응답이 없거나, status가 health가 아닙니다."
        echo "> Health Check: ${HEALTH_CHECK}\n"
      fi

      if [ $count -eq 50 ]; then
        echo "> Health Check 실패"
        echo "> Nginx에 연결하지 않고 배포를 종료합니다."
        exit 1
      fi

      echo "> Health Check 연결 실패. 3초 후 재시도..."
      sleep 3
    done
}


HEALTH_CHECK_ENDPOINT="/health"

if [ $(curl "localhost:8080$HEALTH_CHECK_ENDPOINT" | grep "health" | wc -l ) -gt 0 ]; then
  use_port2
else
  use_port1
fi

print_current_port_info


echo "> 구동 될 Port : $START_PORT"
echo "> 활성화 될 Profile : $START_PROFILE"

echo "> 실행 될 Jar 파일 : $JAR_FILE_NAME"
nohup java -jar $JAR_FILE_NAME --spring.profiles.active=$START_PROFILE &

HEALTH_CHECK_URL="localhost:$START_PORT$HEALTH_CHECK_ENDPOINT"

echo "> 5초 후 Health Check 시작"
echo "> curl -s ${HEALTH_CHECK_URL}"
sleep 5

health_check ${HEALTH_CHECK_URL}
echo "set \$service_url http://127.0.0.1:$START_PORT;" > /etc/nginx/conf.d/service-url.inc

service nginx restart

fuser -k $KILL_PORT/tcp

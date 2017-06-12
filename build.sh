#!/bin/bash

git submodule update --init --recursive

docker build \
    --build-arg SIDEKIQ_CREDS=$SIDEKIQ_CREDS \
    --build-arg DB_ENV_MYSQL_PASS=$DB_ENV_MYSQL_PASS \
    --build-arg DB_ENV_MYSQL_USER=$DB_ENV_MYSQL_USER \
    --build-arg DB_ENV_MYSQL_DB=$DB_ENV_MYSQL_DB \
    --build-arg DB_PORT_3306_TCP_ADDR=$DB_PORT_3306_TCP_ADDR \
    --build-arg REDIS_PORT_6379_TCP_ADDR=$REDIS_PORT_6379_TCP_ADDR \
    --build-arg REDIS_PORT_6379_TCP_PORT=$REDIS_PORT_6379_TCP_PORT \
    --build-arg SMTP_USER_NAME=$SMTP_USER_NAME \
    --build-arg SMTP_PASSWORD=$SMTP_PASSWORD \
    --build-arg SMTP_ADDRESS=$SMTP_ADDRESS \
    --build-arg BITLY_KEY=$BITLY_KEY \
    --build-arg FB_SECRET=$FB_SECRET \
    --build-arg FB_APP_ID=$FB_APP_ID \
    --build-arg FB_SECRET_MHUB=$FB_SECRET_MHUB \
    --build-arg FB_APP_ID_MHUB=$FB_APP_ID_MHUB \
    --build-arg INFOBASE_TOKEN=$INFOBASE_TOKEN \
    --build-arg INFOBASE_URL=$INFOBASE_URL \
    --build-arg SMS_SHORT_CODE=$SMS_SHORT_CODE \
    --build-arg SMS_API_KEY=$SMS_API_KEY \
    --build-arg SMS_DEFAULT_KEYWORD=$SMS_DEFAULT_KEYWORD \
    --build-arg SMS_ENABLED=$SMS_ENABLED \
    --build-arg SUMMER_PROJECT_TOKEN=$SUMMER_PROJECT_TOKEN \
    --build-arg SUMMER_PROJECT_URL=$SUMMER_PROJECT_URL \
    --build-arg TWILIO_ID=$TWILIO_ID \
    --build-arg TWILIO_TOKEN=$TWILIO_TOKEN \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$GIT_COMMIT-$BUILD_NUMBER .
rc=$?

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi

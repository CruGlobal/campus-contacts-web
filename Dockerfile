FROM 056154071827.dkr.ecr.us-east-1.amazonaws.com/base-image-ruby-version-arg:2.3
MAINTAINER cru.org <wmd@cru.org>

# Update node and install yarn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y nodejs yarn

ARG SIDEKIQ_CREDS
ARG RAILS_ENV=production

COPY Gemfile Gemfile.lock ./

RUN bundle config gems.contribsys.com $SIDEKIQ_CREDS
RUN bundle install --jobs 20 --retry 5 --path vendor
RUN bundle binstub puma sidekiq rake

COPY . ./

ARG DB_ENV_MYSQL_USER
ARG DB_ENV_MYSQL_PASS
ARG DB_ENV_MYSQL_DB
ARG DB_PORT_3306_TCP_ADDR
ARG REDIS_PORT_6379_TCP_ADDR
ARG REDIS_PORT_6379_TCP_PORT
ARG SMTP_USER_NAME
ARG SMTP_PASSWORD
ARG SMTP_ADDRESS
ARG BITLY_KEY
ARG FB_SECRET
ARG FB_APP_ID
ARG FB_SECRET_MHUB
ARG FB_APP_ID_MHUB
ARG INFOBASE_TOKEN
ARG INFOBASE_URL
ARG SMS_SHORT_CODE
ARG SMS_API_KEY
ARG SMS_DEFAULT_KEYWORD
ARG SMS_ENABLED
ARG SUMMER_PROJECT_TOKEN
ARG SUMMER_PROJECT_URL
ARG TWILIO_ID
ARG TWILIO_TOKEN
ARG DISABLE_ROLLBAR=true

RUN yarn install --prod
RUN bundle exec rake assets:clobber assets:precompile RAILS_ENV=production

## Run this last to make sure permissions are all correct
RUN mkdir -p /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads && \
  chmod -R ugo+rw /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads

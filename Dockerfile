FROM cruglobal/base-image-ruby:latest
MAINTAINER cru.org <wmd@cru.org>

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

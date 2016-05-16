FROM cruglobal/base-image-ruby-version-arg:2.3.0
MAINTAINER cru.org <wmd@cru.org>

COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

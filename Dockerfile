FROM fabiodcorreia/base-php:1.1.1

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fabiodcorreia"

ENV APP_VERSION=0.29.3
ENV APP_PATH=/var/www/html

WORKDIR ${APP_PATH}

RUN apk add --no-cache \
  memcached \
  ttf-freefont \
	wkhtmltopdf \
  php7-ctype \
  php7-curl \
  php-dom \
  php7-gd \
  php7-memcached \
  php7-mysqlnd \
  php7-pdo_mysql \
  php7-phar \
  php7-tidy \
  php7-tokenizer

RUN \
  echo "**** download bookstack ****" && \
    curl -LJO \
      "https://github.com/BookStackApp/BookStack/archive/v${APP_VERSION}.tar.gz" && \
  echo "**** extrat bookstack ****" && \
    tar -zxvf "BookStack-${APP_VERSION}.tar.gz" --strip-components 1 && \
  echo "**** clean bookstack package ****" && \
    rm "BookStack-${APP_VERSION}.tar.gz" && \
  echo "**** configure php-fpm and php ****" && \
	  sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php7/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php7/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php7/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php7/php.ini && \
  echo "**** install  composer ****" && \
    cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv /tmp/composer.phar /usr/local/bin/composer && \
  echo "**** install composer dependencies ****" && \
    composer install --no-dev -d ${APP_PATH}/ && \
  echo "**** cleanup ****" && \
    rm -rf \
	    /root/.composer \
	    /tmp/* \
      ${APP_PATH}/tests \
      ${APP_PATH}/dev \
      ${APP_PATH}/.github && \
  echo "**** chown abc ****" && \
    chown -R abc:abc \
	  /config \
	  /var/www/ &&\
  echo "**** installation and setup completed ****"

ADD  --chown=abc:abc https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/bin/

# Copy local files
COPY root/ /

# Ports and Volumes
VOLUME /config

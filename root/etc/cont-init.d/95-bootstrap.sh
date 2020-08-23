#!/usr/bin/with-contenv bash

echo "**** create base directories on /config ****"
mkdir -p /config/www/{uploads,files,images}

echo "***** set default log channel to stderr *****"
echo "stderr" > /var/run/s6/container_environment/LOG_CHANNEL

if [ ! -f "${APP_PATH}/.env" ]; then

#TODO its always running this block. maybe I need to set the .env on /config/wwww and then link it to ${APP_PATH}/.env
  chmod +x /usr/bin/wait-for-it.sh

  echo "***** delete base /config/www/index.php *****"
  rm -fr /config/www/index.php

  echo "***** enable php fpm worker log *****"
  echo "catch_workers_output=yes" >> /config/php/www2.conf

	touch "${APP_PATH}/.env"

  echo "APP_ENV=production" >> "${APP_PATH}/.env"
  echo "ALLOW_ROBOTS=false" >> "${APP_PATH}/.env"
  echo "APP_AUTO_LANG_PUBLIC=false" >> "${APP_PATH}/.env"
  echo "CACHE_DRIVER=memcached" >> "${APP_PATH}/.env"
  echo "SESSION_DRIVER=memcached" >> "${APP_PATH}/.env"
  echo "MEMCACHED_SERVERS=127.0.0.1:11211:100" >> "${APP_PATH}/.env"
  echo "APP_DEBUG=${DEBUG:-false}"  >> "${APP_PATH}/.env"

  echo "***** Generating BookStack app key for first run *****"

  key=$(php ${APP_PATH}/artisan key:generate --show)
  echo "APP_KEY=${key}" >> "${APP_PATH}/.env"

  echo "MAIL_DRIVER=smtp" >> "${APP_PATH}/.env"
  echo "MAIL_HOST=${EMAIL_HOST}" >> "${APP_PATH}/.env"
  echo "MAIL_PORT=${EMAIL_PORT}" >> "${APP_PATH}/.env"
  echo "MAIL_USERNAME=${EMAIL_USER}" >> "${APP_PATH}/.env"
  echo "MAIL_PASSWORD=${EMAIL_PASS}" >> "${APP_PATH}/.env"
  echo "MAIL_ENCRYPTION=${EMAIL_SECURE}" >> "${APP_PATH}/.env"
  echo "MAIL_FROM=${EMAIL_FROM}" >> "${APP_PATH}/.env"
  echo "MAIL_FROM_NAME=BookStack" >> "${APP_PATH}/.env"

  echo "DB_HOST=${DATABASE_HOST}" >> "${APP_PATH}/.env"
  echo "DB_DATABASE=${DATABASE_NAME}" >> "${APP_PATH}/.env"
  echo "DB_USERNAME=${DATABASE_USER}" >> "${APP_PATH}/.env"
  echo "DB_PASSWORD=${DATABASE_PASS}" >> "${APP_PATH}/.env"

  echo "APP_URL=${DOMAIN_NAME}" >> "${APP_PATH}/.env"

  echo "STORAGE_TYPE=${STORAGE_TYPE:-'local'}" >>  "${APP_PATH}/.env" #local, local_secure, s3
  echo "STORAGE_S3_KEY=${STORAGE_S3_KEY}" >> "${APP_PATH}/.env"
  echo "STORAGE_S3_SECRET=${STORAGE_S3_SECRET}" >> "${APP_PATH}/.env"
  echo "STORAGE_S3_BUCKET=${STORAGE_S3_BUCKET}" >> "${APP_PATH}/.env"
  echo "STORAGE_S3_ENDPOINT=${STORAGE_S3_ENDPOINT}" >> "${APP_PATH}/.env"
  echo "STORAGE_URL=${STORAGE_URL}" >> "${APP_PATH}/.env"

  echo "**** Default user 'admin@admin.com' with 'password' ****"
else
  sed -i "s/DB_HOST=.+/DB_HOST=${DB_HOST}/g" "${APP_PATH}/.env"
	sed -i "s/DB_DATABASE=.+/DB_DATABASE=${DB_DATABASE}/g" "${APP_PATH}/.env"
	sed -i "s/DB_USERNAME=.+/DB_USERNAME=${DB_USER}/g" "${APP_PATH}/.env"
	sed -i "s/DB_PASSWORD=.+/DB_PASSWORD=${DB_PASS}/g" "${APP_PATH}/.env"

  sed -i "s/MAIL_HOST=.+/MAIL_HOST=${EMAIL_HOST}/g" "${APP_PATH}/.env"
  sed -i "s/MAIL_PORT=.+/MAIL_PORT=${EMAIL_PORT}/g" "${APP_PATH}/.env"
  sed -i "s/MAIL_USERNAME=.+/MAIL_USERNAME=${EMAIL_USER}/g" "${APP_PATH}/.env"
  sed -i "s/MAIL_PASSWORD=.+/MAIL_PASSWORD=${EMAIL_PASS}/g" "${APP_PATH}/.env"
  sed -i "s/MAIL_ENCRYPTION=.+/MAIL_ENCRYPTION=${EMAIL_SECURE}/g" "${APP_PATH}/.env"
  sed -i "s/MAIL_FROM=.+/MAIL_FROM=${EMAIL_FROM}/g" "${APP_PATH}/.env"

  sed -i "s/APP_URL=.+/APP_URL=${DOMAIN_NAME}/g" "${APP_PATH}/.env"
  sed -i "s/APP_DEBUG=.+/APP_DEBUG=${DEBUG:-false}/g" "${APP_PATH}/.env"
fi

# Check database connection before migrations
wait-for-it.sh "${DATABASE_HOST}:3306" -t 30
sleep 5 #Wait in case of intermitent up container
wait-for-it.sh "${DATABASE_HOST}:3306" -t 30

php "${APP_PATH}/artisan" migrate --force


echo "**** set volume links ****"

#mkdir -p "${APP_PATH}/storage/logs"
#ln -s /dev/stdout "${APP_PATH}/storage/logs/laravel.log"

# create symlinks
symlinks=( \
  "${APP_PATH}/storage/uploads/files" \
  "${APP_PATH}/storage/uploads/images" \
  "${APP_PATH}/public/uploads" \
)

for i in "${symlinks[@]}"
do
[[ -e "$i" && ! -L "$i" ]] && rm -rf "$i"
  [[ ! -L "$i" ]] && ln -s /config/www/"$(basename "$i")" "$i"
done

echo "**** chown /config and /var/www ****"
chown -R abc:abc \
	/config \
	/var/www/

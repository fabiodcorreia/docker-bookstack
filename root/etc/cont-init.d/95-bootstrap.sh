#!/usr/bin/with-contenv bash

echo "**** create base directories on /config ****"
mkdir -p /config/www/{uploads,files,images}

#echo "***** set default log channel to stderr *****"
#echo "stderr" > /var/run/s6/container_environment/LOG_CHANNEL

echo "**** chown /config and /var/www in background ****"
chown -R abc:abc /config /var/www/ &&

if [ ! -f /config/www/key.txt ]; then
  echo "***** Generating BookStack app key for first run *****"
  KEY=$(php ${APP_PATH}/artisan key:generate --show)
  echo $KEY > /config/www/key.txt

  echo "***** delete base /config/www/index.php *****"
  rm -fr /config/www/index.php

  echo "***** enable php fpm worker log *****"
  echo "catch_workers_output=yes" >> /config/php/www2.conf

  echo "**** Default user 'admin@admin.com' with 'password' ****"
fi

KEY=`cat /config/www/key.txt`

cat <<END > ${APP_PATH}/.env
APP_ENV=production
ALLOW_ROBOTS=false
APP_AUTO_LANG_PUBLIC=false
AUTH_METHOD=standard
APP_LANG=en
CACHE_DRIVER=memcached
SESSION_DRIVER=memcached
CACHE_PREFIX=bookstack
MEMCACHED_SERVERS=127.0.0.1:11211:100
SESSION_SECURE_COOKIE=false

APP_DEBUG=${DEBUG:-false}
APP_KEY=${KEY}
APP_URL=${DOMAIN_NAME}

DB_HOST=${DATABASE_HOST}
DB_PORT=3306
DB_DATABASE=${DATABASE_NAME}
DB_USERNAME=${DATABASE_USER}
DB_PASSWORD=${DATABASE_PASS}

MAIL_DRIVER=smtp
MAIL_FROM=${EMAIL_FROM}
MAIL_FROM_NAME=BookStack
MAIL_HOST=${EMAIL_HOST}
MAIL_PORT=${EMAIL_PORT}
MAIL_USERNAME=${EMAIL_USER}
MAIL_PASSWORD=${EMAIL_PASS}
MAIL_ENCRYPTION=${EMAIL_SECURE}

STORAGE_TYPE=${STORAGE_TYPE:-'local'}

STORAGE_S3_KEY=${STORAGE_S3_KEY}
STORAGE_S3_SECRET=${STORAGE_S3_SECRET}
STORAGE_S3_BUCKET=${STORAGE_S3_BUCKET}
STORAGE_S3_ENDPOINT=${STORAGE_S3_ENDPOINT}
STORAGE_URL=${STORAGE_URL}
END

chmod +x /usr/bin/wait-for-it.sh
# Check database connection before migrations
wait-for-it.sh "${DATABASE_HOST}:3306" -t 30
sleep 5 #Wait in case of intermitent up container
wait-for-it.sh "${DATABASE_HOST}:3306" -t 30

echo "**** apply database migrations ****"
php "${APP_PATH}/artisan" migrate --force

echo "**** set volume links ****"

mkdir -p "${APP_PATH}/storage/logs"
ln -s /dev/stdout "${APP_PATH}/storage/logs/laravel.log"

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

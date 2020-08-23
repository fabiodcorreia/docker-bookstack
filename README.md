# Docker Bookstack Image

![Maintenance](https://img.shields.io/maintenance/yes/2020?style=plastic) [![Drone Status](https://img.shields.io/drone/build/fabiodcorreia/docker-bookstack?style=plastic)](https://cloud.drone.io/fabiodcorreia/docker-bookstack) [![Latest Release](https://img.shields.io/github/v/release/fabiodcorreia/docker-bookstack?style=plastic)](https://github.com/fabiodcorreia/docker-bookstack/releases/latest) [![GitHub Licence](https://img.shields.io/github/license/fabiodcorreia/docker-bookstack?style=plastic)](https://github.com/fabiodcorreia/docker-bookstack/blob/master/LICENSE)


![MicroBadger Layers](https://img.shields.io/microbadger/layers/fabiodcorreia/bookstack?style=plastic) [![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/fabiodcorreia/bookstack?style=plastic)](https://hub.docker.com/r/fabiodcorreia/bookstack) [![Docker Pulls](https://img.shields.io/docker/pulls/fabiodcorreia/bookstack?style=plastic)](https://hub.docker.com/r/fabiodcorreia/bookstack) ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/fabiodcorreia/bookstack?sort=semver&style=plastic)

A custom Bookstack image build with Alpine Linux and NGINX/PHP.

## Base Packages

- memcached
- ttf-freefont
- wkhtmltopdf
- php7-ctype
- php7-curl
- php-dom
- php7-gd
- php7-memcached
- php7-mysqlnd
- php7-pdo_mysql
- php7-phar
- php7-tidy
- php7-tokenizer

## Versioning

This image follows the [Semantic Versioning](https://semver.org/) pattern.

- **MAJOR** version - Changes on Base Image version (1.0.0 to 2.0.0)
- **MINOR** version - Changes on Bookstack version (2.1.4 to 2.1.5)
- **PATCH** version - Package updates and other non breaking changes on the image
- **DRAFT** version - Unstable build for review (Optional)

### Version Mapping

| Version    | 1.0     | 1.1     | 2.0     |
| :----:     | ---     | ---     | ----    |
| Base Image | 1.x.x   | 1.x.x   | 2.x.x   |
| bookstack   | 0.29.2   | 0.29.3   | 0.29.2   |

When Base Image gets upgraded the major version is incremented, when Bookstack gets upgraded the minor version is incremented.

## Tags

| Tag | Description |
| :----: | --- |
| latest | Latest version |
| 1.0.0 | Specific patch version |
| 1.0 | Specific minor version |
| 1 | Specific major version |
| 1.0.0-`arch` | Specific patch version to that `arch` |
| 1.0-`arch` | Specific minor version to that `arch` |
| 1-`arch` | Specific major version to that `arch` |
| test | Branch version - **DO NOT USE** |

The version tags are the same as the repository versioning tags but without the `v`. The `test` version is only for build purposes, it should not be pulled.

The `arch` can be one of the supported architectures described below.

## Supported Architectures

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64 |
| arm64 | arm64v8 |
| armhf | arm32v7 |


## Environment Variables

| Name                  | Description |
| :-------------------: | ----------- |
| PUID                  | Set the UserID - [Details](https://github.com/fabiodcorreia/docker-base-alpine#userid--groupid) |
| PGID                  | Set the GroupID - [Details](https://github.com/fabiodcorreia/docker-base-alpine#userid--groupid) |
| TZ                    | Set the system timezone - [Options](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| HTTP_TRACE            | Enable HTTP trace Log (default: false) |
| DEBUG                 | Enable debug logs |
| DATABASE_HOST         | Set the database hostname or ip address where the application will connect |
| DATABASE_NAME         | Set the database name that will be used by the application |
| DATABASE_USER         | Set the username for the database connection |
| DATABASE_PASS         | Set the password for the database username |
| DOMAIN_NAME           | Set the application domain name in case of reverse proxy |
| EMAIL_HOST            | Set the SMTP server hostname |
| EMAIL_PORT            | Set the SMTP server port |
| EMAIL_USER            | Set the SMTP username |
| EMAIL_PASS            | Set the SMPT password |
| EMAIL_SECURE          | Set the SMTP security protocol (TLS, SSL, STARTTLS)
| EMAIL_FROM            | Set the SMTP email FROM |
| STORAGE_TYPE          | Set storage system to use 'local', 'local_secure', 's3' |
| STORAGE_S3_KEY        | Set storage s3 key |
| STORAGE_S3_SECRET     | Set storage s3 secret |
| STORAGE_S3_BUCKET     | Set storage s3 bucket name |
| STORAGE_S3_ENDPOINT   | Set storage s3 endpoint for s3 compatibile services 'https://my-custom-s3-compatible.service.com' |
| STORAGE_URL           | Set storate s3 URL format, if not set then S3 compatible URL will be generated |


## Volumes and Ports

It exposes a single volume at `/config` where it keeps the configuration and other files related with the application.

Also a single port is exposed at 80 to allow external connections to the database.

## Start Container

```bash
docker run \
  -e PUID=1000 \
  -e PGID=1000 \
  -e DATABASE_HOST=mariadb_bookstack \
  -e DATABASE_NAME=bookstackdb \
  -e DATABASE_USER=bookstackuser \
  -e DATABASE_PASS=bookstackpass \
  -p 80:80 \
  -v $PWD:/config \
  fabiodcorreia/bookstack
```

Or use `docker-compose`, an example is provided on [docker-compose.yml](docker-compose.yml)

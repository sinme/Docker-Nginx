# Quick Start LNMP:

```bash
yum install wget git && \
curl -fsSL https://get.docker.com/ | sh && \
service docker start && \
curl -L https://github.com/docker/compose/releases/download/1.8.0-rc2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose && \
wget http://mirrors.svipc.com/Docker/docker-compose-lnmp.yml -O docker-compose.yml && \
docker-compose up -d
```

# MariaDB Passwd：
www.svipc.com

# Supervisord Passwd：
www.svipc.com

# Docker-composr configure:

```bash
version: '2'

services:
    php:
        #build:
        #    context: https://github.com/LongTaiJun/Docker-PHP.git
        container_name: php
        restart: always
        privileged: true
        image: longtaijun/php:latest
        volumes:
        - /etc/localtime:/etc/localtime:ro
        - /data/wwwroot:/data/wwwroot:rw
    mariadb:
        #build:
        #    context: https://github.com/LongTaiJun/Docker-MariaDB.git
        container_name: mariadb
        restart: always
        privileged: true
        image: longtaijun/mariadb:latest
        ports:
        - "3306:3306"
        environment:
        - MYSQL_ROOT_PASSWORD=www.svipc.com
        volumes:
        - /etc/localtime:/etc/localtime:ro
        - /data/mariadb:/data/mariadb:rw
    nginx:
        #build:
        #    context: https://github.com/LongTaiJun/Docker-Nginx.git
        container_name: nginx
        restart: always
        privileged: true
        image: longtaijun/nginx:latest
        ports:
        - "80:80"
        - "443:443"
        links:
        - php:php
        - mariadb:mariadb
        volumes_from:
        - php
        environment:
        - PHP_FPM=Yes
        - PHP_FPM_SERVER=php
        - PHP_FPM_PORT=9000
        - REWRITE=wordpress
        volumes:
        - /etc/localtime:/etc/localtime:ro
        - /data/wwwroot:/data/wwwroot:rw
        - /data/logs/wwwlogs:/data/wwwlogs:rw
        - /data/conf/nginx/vhost:/usr/local/nginx/conf/vhost:rw
```





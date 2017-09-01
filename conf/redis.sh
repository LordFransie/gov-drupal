#!/bin/bash

#Install Redis Server
yum install redis -y

#Instal PHP Redis
cd /tmp
git clone git://github.com/nicolasff/phpredis.git
cd phpredis
phpize
./configure
make
make install

#Update Php Config
echo "extension=redis.so">/etc/php.d/redis.ini

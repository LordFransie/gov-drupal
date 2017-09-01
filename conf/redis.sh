#!/bin/bash
# Install PHP Redis
cd /tmp
git clone git://github.com/nicolasff/phpredis.git
cd phpredis
phpize
./configure
make
make install

# Update Php Config
echo "extension=redis.so">/etc/php.d/redis.ini

# Apply changes to Apache
httpd -k graceful
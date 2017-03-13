FROM centos:7
MAINTAINER Ron Williams <hello@ronwilliams.io>
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set TERM env to avoid mysql client error message "TERM environment variable not set" when running from inside the container
ENV TERM xterm

# Fix command line compile issue with bundler.
ENV LC_ALL en_US.utf8

# Custom docroot (see conf/run-httpd.sh)
ENV DOCROOT /var/www/public

# Install and enable repositories
RUN yum -y update && \
    yum -y install epel-release && \
    rpm -Uvh https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y update

RUN yum -y install \
    curl \
    git \
    mariadb \
    msmtp \
    net-tools \
    python34 \
    vim \
    wget \

# Install PHP and PHP modules
RUN yum -y install \
    php56u \
    php56u-curl \
    php56u-gd \
    php56u-imap \
    php56u-mbstring \
    php56u-mcrypt \
    php56u-mysql \
    php56u-odbc \
    php56u-pear \
    php56u-pecl-imagick \
    php56u-pecl-zendopcache

# Install misc tools
RUN yum -y install \
    python-setuptools

# Perform yum cleanup
RUN yum -y upgrade && \
    yum clean all

# Install Composer and Drush
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --version=1.0.0-alpha10 && \
    composer \
    --working-dir=/usr/local/src/ \
    global \
    require \
    drush/drush:7.* && \
    ln -s /usr/local/src/vendor/bin/drush /usr/bin/drush

RUN drush @none dl registry_rebuild-7.x
RUN drush @none dl utf8mb4_convert-7.x

# Disable services management by systemd.
RUN systemctl disable httpd.service

# Apache config, and PHP config, test apache config
# See https://github.com/docker/docker/issues/7511 /tmp usage
COPY public/index.php /var/www/public/index.php
COPY centos-7 /tmp/centos-7/
RUN rsync -a /tmp/centos-7/etc/ /etc/ && \
    apachectl configtest

EXPOSE 80 443

# Simple startup script to avoid some issues observed with container restart 
ADD conf/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

ADD conf/mail.ini /etc/php.d/mail.ini
RUN chmod 644 /etc/php.d/mail.ini

CMD ["/run-httpd.sh"]

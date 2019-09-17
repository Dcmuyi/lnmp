FROM php:7.0-fpm

ENV TZ=Asia/Shanghai

# use chinese mirror for apt-update
RUN sed -i "s/archive.ubuntu.com/cn.archive.ubuntu.com/g" /etc/apt/sources.list

RUN set -xe \
    && echo "安装 php 以及编译构建组件所需包" \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y build-essential libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libmcrypt4 mongodb --no-install-recommends \
    && echo "编译安装 php 组件" \
    && docker-php-ext-install pcntl iconv mcrypt mysqli pdo_mysql zip bcmath mbstring \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN set -xe \
    && pecl install mongodb igbinary redis Inotify yaf

#install phalcon
#ARG PHALCON_VERSION=3.4.2
#ARG PHALCON_EXT_PATH=php7/64bits
#
#RUN set -xe && \
#        # Compile Phalcon
#        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
#        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
#        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} && \
#        # Remove all temp files
#        rm -r \
#            ${PWD}/v${PHALCON_VERSION}.tar.gz \
#            ${PWD}/cphalcon-${PHALCON_VERSION}

#COPY docker-phalcon-* /usr/local/bin/
COPY ./conf/php/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php/php-fpm.d/site.conf /usr/local/etc/php-fpm.d/site.conf

RUN set -xe \
    && echo "配置workerman所需data文件夹" \
    && mkdir -p /data/run \
    && mkdir -p /data/logs/workerman \
    && chmod -R 777 /data
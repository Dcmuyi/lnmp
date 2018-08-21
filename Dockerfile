FROM php:7.0-fpm

ENV TZ=Asia/Shanghai

#COPY sources.list /etc/apt/sources.list

RUN set -xe \
    && echo "安装 php 以及编译构建组件所需包" \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y build-essential libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libmcrypt4 --no-install-recommends \
    && echo "编译安装 php 组件" \
    && docker-php-ext-install iconv mcrypt mysqli pdo_mysql zip bcmath mbstring \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && echo "清理" \
    && apt-get purge -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false \
        $buildDeps \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/php/php.ini /usr/local/etc/php/php.ini
COPY ./conf/php/php-fpm.d/site.conf /usr/local/etc/php-fpm.d/site.conf
FROM php:7-fpm

ENV TZ=Asia/Shanghai

COPY sources.list /etc/apt/sources.list
#pdo_dblib需要文件，freetds需要
COPY ./conf/freetds/libsybdb.a /usr/lib/

RUN set -xe \
    && echo "构建依赖" \
    && buildDeps=" \
        build-essential \
        php5-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    " \
    && echo "运行依赖" \
    && runtimeDeps=" \
        libfreetype6 \
        libjpeg62-turbo \
        freetds-bin \
        freetds-dev \
        freetds-common \
        libmcrypt4 \
        libpng12-0 \
    " \
    && echo "安装 php 以及编译构建组件所需包" \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y ${runtimeDeps} ${buildDeps} --no-install-recommends \
    && echo "编译安装 php 组件" \
    && docker-php-ext-install iconv mcrypt mysqli pdo pdo_mysql pdo_dblib zip bcmath mbstring \
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
COPY ./conf/freetds/freetds.conf /etc/freetds/freetds.conf
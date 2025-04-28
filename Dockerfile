FROM ubuntu:latest

# Essentials
ENV TZ=America/Fortaleza
RUN echo $TZ > /etc/timezone \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -yqq \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    #libaio1 \
    libaio-dev \
    g++ \
    make \
    zip \
    unzip \
    curl \
    nano \
    supervisor \
    bash \
    wget

RUN add-apt-repository ppa:ondrej/php \
    && apt-get -yqq update

WORKDIR /src

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x 565 | bash - \
    && apt-get install nodejs

# NGINX
RUN apt-get -y install nginx
COPY app.conf /etc/nginx/conf.d/app.conf

# PHP82
RUN apt-get update \
    && apt-get install -yqq php8.2 \
    php8.2-common \
    php8.2-fpm \
    php8.2-dev \
    php8.2-pdo \
    php8.2-opcache \
    php8.2-zip \
    php8.2-phar \
    php8.2-iconv \
    php8.2-cli \
    php8.2-curl \
    php8.2-mbstring \
    php8.2-tokenizer \
    php8.2-fileinfo \
    php8.2-xml \
    php8.2-xmlwriter \
    php8.2-simplexml \
    php8.2-dom \
    php8.2-tokenizer \
    php8.2-redis \
    php8.2-xdebug \
    php8.2-gd \
    php8.2-mysql \
    php8.2-ldap \
    php8.2-sqlite3 \
    php8.2-intl

# Configuracoes do PHP
RUN linhas=$(grep -m1 -n "listen =" /etc/php/8.2/fpm/pool.d/www.conf | cut -f1 -d:) \
    && sed -i "${linhas}d" /etc/php/8.2/fpm/pool.d/www.conf \
    && sed -i "${linhas}i listen=127.0.0.1:9000" /etc/php/8.2/fpm/pool.d/www.conf

RUN max_cli=$(grep -m1 -n "max_execution_time" /etc/php/8.2/cli/php.ini | cut -f1 -d:) \
    && sed -i "${max_cli}d" /etc/php/8.2/cli/php.ini \
    && sed -i "${max_cli}i max_execution_time = 240" /etc/php/8.2/cli/php.ini 

RUN max_fpm=$(grep -m1 -n "max_execution_time" /etc/php/8.2/fpm/php.ini | cut -f1 -d:) \
    && sed -i "${max_fpm}d" /etc/php/8.2/fpm/php.ini \
    && sed -i "${max_fpm}i max_execution_time = 240" /etc/php/8.2/fpm/php.ini 

# Xdebug
#COPY xdebug.ini "${PHP_INI_DIR}/conf.d"

# Composer
ARG HASH="`curl -sS https://composer.github.io/installer.sig`"
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === $HASH) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# Supervisor
RUN mkdir -p /etc/supervisor.d/
COPY supervisord.ini /etc/supervisor.d/supervisord.ini

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

CMD [ "supervisord", "-c", "/etc/supervisor.d/supervisord.ini" ]
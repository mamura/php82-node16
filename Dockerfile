FROM ubuntu:latest

# Essentials
ENV TZ=America/Fortaleza
RUN echo $TZ > /etc/timezone \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -iqq \
    lsb-release \
    ca-certificates \
    apt-transport-http \
    software-properties-common \
    libaio1 \
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

RUN add-repository ppa:ondrej/php \
    && apt-get -yqq update

WORKDIR /src

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x 565 | bash - \
    && apt-get install nodejs

# NGINX
RUN apt-get -y install nginx
COPY app.conf /etc/nginx/conf.d/app.conf
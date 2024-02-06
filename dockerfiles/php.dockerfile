FROM php:7.4-fpm-alpine

# Install needed php extensions
# The official php image has a tool `docker-php-ext-install` which is highlighted in the official image [documentation](https://hub.docker.com/_/php). This can be used to install php extensions
# set the working directory to where we want the plugins installed
WORKDIR /var/www/html 
# Install the needed plugins
RUN docker-php-ext-install pdo pdo_mysql 

# We don't have a command or entry point. Thus the base images command will be used
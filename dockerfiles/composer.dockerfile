FROM composer:latest

# This is where our code will be
WORKDIR /var/www/html 

ENTRYPOINT [ "composer", "--ignore-platform-reqs" ]
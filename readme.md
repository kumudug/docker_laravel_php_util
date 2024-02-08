![overview](./lareval-docker.jpg)

# Overview

This is a demo of setting up a laravel php dev environment using the Docker "util" concept introduced by [Maximilian Schwarzmüller](https://www.udemy.com/user/maximilian-schwarzmuller/)

# Target Setup Components

* Application Containers - App containers that are gonna be running all the time

   * PHP Interpretter
      - Interprets php and generates a response
      - Runs php code
   * Nginx web server
      - Web server which takes the incoming request, takes it to the PHP Interpretter and generates the response
   * MySQL Database 
      - DB for storing data
      - PHP Interpretter communicates with the db

* Utility Containers - Laravel needs 3 kinds of utilities/tools

   * Composer
      * Composer for PHP is what npm is for node
      * Package manager to install 3rd party packages
      * Used to install laravel
      * Then laravel uses this to install dependencies
      * Composer is a dependency manager written in and for PHP.

   * Laravel Artisan
      * A tool for laravel

   * npm
      - laravel uses npm for some of its front end logic

# Target Setup Compose File

* We will be using docker compose to setup the all the needed containers.

## NGINX web server

* The image used is the official NGINX docker image. - [docker-hub-nginx](https://hub.docker.com/_/nginx)
   - The version/tag used is `stable-alpine`
   - The web server is on port 80 (according to the docker hub documentation)
   - The containers local port `80` will be exposed to outside port `8000`
   - In order to customize the default config we need to mount a config file to the image location `/etc/nginx/nginx.conf` as specified in the docker hub image documentation

## PHP Interpretter

* We are gonna build our own image based on the official php docker image
   - For the nginx config we are using we need a php-fpm image
   - FPM, which is a FastCGI implementation for PHP
   - The official php image has a tool `docker-php-ext-install` which is highlighted in the official image [documentation](https://hub.docker.com/_/php). This can be used to install php extensions
   - We do not specify a command in our docker file. Thus the base images default command will get executed
   - Bind the src folder to the php image so we can develop in the local machine
   - `:delegated` option makes the changes from container to bind mound eventually consistant. Whichc makes it faster
   - With `gRPC-FUSE` these flags were made redundant
   - Port
     - We need to use port `3000`. This is defined in the `nginx.conf` we provided via a bind mount to the nginx server. So if needed we can change it
     - official dockerfile exposes port `9000`. This was found using [Dockerfile](https://github.com/docker-library/php/blob/b9f17156020c3aef71df681b27684533529347a7/7.4/alpine3.16/fpm/Dockerfile) in the images github repo. Not from documentation
     - Since its nginx and php that needs to cummunicate with these ports there is no reason why we need to map these ports. Instead we can change the `nginx.conf` to point to the php port `9000` and be done with it

## MySQL Database

* Using the official mysql image [image](https://hub.docker.com/_/mysql)
   - Using version 5.7
   - Use environment variables to set 
      - MYSQL_DATABASE - initial database name set to `homestead`. This is needed for laravel and can be found in laravel documentation
      - MYSQL_USER=homestead - default for laravel
      - MYSQL_PASSWORD=secreat
      - MYSQL_ROOT_PASSWORD=secreat

## Composer Tool

* There is an official docker image for this tool
   - [docker-img](https://hub.docker.com/_/composer)
   - We are building our own image based on the official docker image with some customizations
   - We wanna specify the entry point. Though this can be done via `compose.yaml` its more clear and readable to have a `.dockerfile` and create a custom image
   - We are using this image to install packages. We want the packages installed in our source folder
   - We bound our local disk `src` folder to `/var/www/html` in the php container
   - Now we want the composer to install packages there. Thus we are binding our local `src` folder into the composer container as well at `/var/www/html`
   - So this gets connected to php container via local disk

# Setting up a laravel project

* We are gonna use the `composer` image and run a one time command using docker compose. This will create a laravel project for us in the src folder. 
   - `docker compose run --rm composer create-project --perfer-dist laravel/laravel .`

# Running

* `docker compose up -d server php mysql`
* By adding `depends_on` to the `server` service we can start that only and not need to input all needed services
   - Now we can do `docker compose up -d server`
* To force docker compose to go through images and rebuild if something changed we should also use the `--build` flag
   - `docker compose up -d --build server`
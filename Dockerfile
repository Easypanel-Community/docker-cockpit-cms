FROM php:7.3-apache

RUN apt-get update \
    && apt-get install -y \
		wget zip unzip \
        libzip-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        sqlite3 libsqlite3-dev \
        libssl-dev \
    && pecl install mongodb \
    && pecl install redis \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv gd pdo zip opcache pdo_sqlite \
    && a2enmod rewrite expires

RUN echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb.ini
RUN echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

RUN wget https://files.getcockpit.com/releases/master/cockpit-core.zip -O /tmp/cockpit.zip; unzip /tmp/cockpit.zip -d /tmp/; rm /tmp/cockpit.zip
RUN mv /tmp/cockpit-${COCKPIT_VERSION}/.htaccess /var/www/html/.htaccess
RUN mv /tmp/cockpit-${COCKPIT_VERSION}/* /var/www/html/
RUN rm -R /tmp/cockpit-${COCKPIT_VERSION}/
RUN echo "\n\nphp_value post_max_size 256M" >> /var/www/html/.htaccess
RUN echo "\nphp_value  upload_max_filesize 256M" >> /var/www/html/.htaccess

RUN chown -R www-data:www-data /var/www/html

VOLUME /var/www/html

CMD ["apache2-foreground"]

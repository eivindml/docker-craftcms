FROM php:7.2-apache

RUN apt-get update \
	&& apt-get install -yq apt-utils unzip libmcrypt-dev libmagickwand-dev \
	&& docker-php-ext-install zip pdo_mysql mcrypt \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& rm -rf /var/lib/apt/lists/*

# Enable .htaccess
RUN a2enmod rewrite

# Install Craft CMS
ADD https://craftcms.com/latest-v3.zip /tmp/latest-v3.zip

RUN unzip -q /tmp/latest-v3.zip -d /var/www/
RUN rm /tmp/latest-v3.zip
RUN mv /var/www/web/* /var/www/html/
RUN mv /var/www/web/.htaccess /var/www/html/.htaccess
RUN rmdir /var/www/web

# Set permissions
RUN chown -R www-data:www-data \
	/var/www/.env \
	/var/www/composer.json \
	/var/www/composer.lock \
	/var/www/storage/* \
	/var/www/vendor/* \
	/var/www/config/*

RUN chmod 777 /var/www/config/
RUN chmod 777 /var/www/storage/
RUN chmod 777 /var/www/html/cpresources/

# Copy .env file
COPY .env /var/www/

# Generate Key
RUN chmod +x /var/www/craft
RUN /var/www/craft setup/security-key

# Copy source to image
# COPY src/ /var/www/html

# Expose default port
EXPOSE 80

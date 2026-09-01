ARG PHP_VERSION=8.3
FROM jakzal/phpqa:php${PHP_VERSION}

RUN apt update
RUN apt upgrade -y

RUN apt install -y \
	acl \
	file \
	gettext \
	git \
	python3 \
	make \
	libzip-dev \
	libxml2-dev \
	libxslt-dev \
	libpng-dev libwebp-dev libjpeg-dev libfreetype6-dev libxml-xpath-perl \
	redis libgd3 rsync \
	wget unzip jq chromium chromium-driver;

RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    intl \
    zip \
    xml \
    xsl \
    gd \
    soap;

# Remove nodejs/npm if present (ignore errors if not installed)
RUN apt remove --purge nodejs npm || true
RUN apt clean
RUN rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/npm* || true

RUN mkdir -p /usr/src/php/ext/redis; \
	curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
	docker-php-ext-install redis;

RUN mkdir /drivers
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v0.32.0/geckodriver-v0.32.0-linux64.tar.gz; \
    tar -zxf geckodriver-v0.32.0-linux64.tar.gz -C /usr/bin; \
    tar -zxf geckodriver-v0.32.0-linux64.tar.gz -C /drivers; \
    rm geckodriver-v0.32.0-linux64.tar.gz
    
RUN ln -sf /usr/bin/chromedriver /drivers/chromedriver

RUN wget -q https://raw.githubusercontent.com/platformsh/cli/main/installer.sh; \
    bash installer.sh INSTALL_DIR=/usr/bin;\
    rm installer.sh

RUN yes | pecl install xdebug-3.4.1 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-enable redis.so
RUN docker-php-ext-install gd

RUN composer global bin phpstan require ekino/phpstan-banned-code
# Security checker is now abandoned by fabpot, but we need it for backward compatibility with some projects. We will install it anyway.
RUN wget -q https://github.com/fabpot/local-php-security-checker/releases/download/v2.1.3/local-php-security-checker_linux_amd64 -O /tools/local-php-security-checker
RUN chmod +x /tools/local-php-security-checker
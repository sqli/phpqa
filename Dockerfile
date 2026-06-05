ARG PHP_VERSION=8.4
FROM jakzal/phpqa:php${PHP_VERSION}

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
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
  wget unzip jq chromium-common chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

RUN apt remove --purge nodejs npm || true
RUN apt clean
RUN rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/npm*

RUN mkdir -p /usr/src/php/ext/redis; \
	curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
	docker-php-ext-install redis;

RUN mkdir /drivers
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v0.32.0/geckodriver-v0.32.0-linux64.tar.gz; \
    tar -zxf geckodriver-v0.32.0-linux64.tar.gz -C /usr/bin; \
    tar -zxf geckodriver-v0.32.0-linux64.tar.gz -C /drivers; \
    rm geckodriver-v0.32.0-linux64.tar.gz

RUN wget -q https://chromedriver.storage.googleapis.com/90.0.4430.24/chromedriver_linux64.zip; \
    unzip chromedriver_linux64.zip -d /usr/bin; \
    unzip chromedriver_linux64.zip -d /drivers; \
    rm chromedriver_linux64.zip

RUN wget -q https://raw.githubusercontent.com/platformsh/cli/main/installer.sh; \
    bash installer.sh INSTALL_DIR=/usr/bin;\
    rm installer.sh

RUN yes | pecl install xdebug-3.5.1 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-enable redis.so
RUN docker-php-ext-install gd

RUN composer global bin phpstan require ekino/phpstan-banned-code

# Create non-root user
RUN groupadd -g 1001 phpqauser && useradd -r -u 1001 -g phpqauser phpqauser

# Change ownership of necessary directory
RUN mkdir -p /project && chown -R phpqauser:phpqauser /project

# Run everything as non-root
USER phpqauser
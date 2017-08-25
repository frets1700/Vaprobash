#!/usr/bin/env bash

PHP_VERSION=$1

echo ">>> Installing Mailcatcher"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

# Installing dependency
# -qq implies -y --force-yes
sudo apt-add-repository ppa:brightbox/ruby-ng -y
sudo apt-get update
sudo apt-get install -qq libsqlite3-dev ruby2.2 ruby2.2-dev

if $(which rvm) -v > /dev/null 2>&1; then
	echo ">>>>Installing with RVM"
	$(which rvm) default@mailcatcher --create do gem install --no-rdoc --no-ri mailcatcher
	$(which rvm) wrapper default@mailcatcher --no-prefix mailcatcher catchmail
else
	# Gem check
	if ! gem -v > /dev/null 2>&1; then sudo aptitude install -y libgemplugin-ruby; fi

	# Install
	gem install --no-rdoc --no-ri mailcatcher
fi

# Make it start on boot
sudo tee /etc/init/mailcatcher.conf <<EOL
description "Mailcatcher"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
exec /usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
EOL

# Start Mailcatcher
sudo service mailcatcher start

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
	# Make php use it to send mail
    echo "sendmail_path = /usr/bin/env $(which catchmail)" | sudo tee /etc/php/${PHP_VERSION}/mods-available/mailcatcher.ini
	sudo phpenmod mailcatcher
	sudo service php${PHP_VERSION}-fpm restart
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
	sudo service apache2 restart
fi

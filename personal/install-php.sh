#!/bin/bash

Help()
{
   # Display Help
   echo "PHP installation script"
   echo
   echo "Syntax: php-install.sh [-h|v]"
   echo "options:"
   echo "h     Print this Help."
   echo "v     The PHP version to be installed (Ex: 8.x, 7.x)."
   echo
}

# Set default installed PHP version
PHP_VERSION=""

# Get the options
while getopts ":hv:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      v) # Set php version
         PHP_VERSION=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [[ -z $PHP_VERSION ]]; then
    echo "Error: PHP version not specified"
    exit 1
fi

echo "PHP version to be installed $PHP_VERSION"

sudo apt install -y php$PHP_VERSION
sudo apt install -y php$PHP_VERSION-bcmath \
	php$PHP_VERSION-mysql \
	php$PHP_VERSION-curl \
	php$PHP_VERSION-mbstring \
	php$PHP_VERSION-tokenizer \
	php$PHP_VERSION-xml \
	php$PHP_VERSION-xmlrpc \
	php$PHP_VERSION-common \
	php$PHP_VERSION-zip \
	php$PHP_VERSION-soap \
	php$PHP_VERSION-gd \
	php$PHP_VERSION-fpm \
	php$PHP_VERSION-intl


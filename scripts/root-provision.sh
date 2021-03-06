#!/bin/bash

function apt_ppa_repository_with_key {
  wget --quiet -O - "$2" | apt-key add -
  sh -c "echo '$3' >> $1"
}

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

UBUNTU_CODENAME=$(lsb_release --codename | cut -f2)

echo "Configuring locale"
echo 'LC_ALL="en_US.utf8"' >> /etc/environment

echo "Forward ssh"
echo "Defaults env_keep+=SSH_AUTH_SOCK" >> /etc/sudoers

echo "Setting up repositories..."

# ruby2.3
add-apt-repository --yes ppa:brightbox/ruby-ng

apt_ppa_repository_with_key "/etc/apt/sources.list.d/postgresql.list" "https://www.postgresql.org/media/keys/ACCC4CF8.asc" "deb http://apt.postgresql.org/pub/repos/apt/ $UBUNTU_CODENAME-pgdg main"
apt_ppa_repository_with_key "/etc/apt/sources.list.d/passenger.list" "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x561F9B9CAC40B2F7" "deb https://oss-binaries.phusionpassenger.com/apt/passenger $UBUNTU_CODENAME main"
apt_ppa_repository_with_key "/etc/apt/sources.list.d/google.list" "https://dl-ssl.google.com/linux/linux_signing_key.pub" "deb http://dl.google.com/linux/chrome/deb/ stable main"

# Mysql credentials
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "Updating repositories..."
apt-get update

echo "Installing packages..."

packages=(
  # build essential
  build-essential
  # automatic configure script builder
  autoconf
  # compilation
  make
  # makefiles
  automake
  # unzip
  unzip

  # ruby libs dependencies
  libssl-dev
  libyaml-dev
  libreadline6
  libreadline6-dev
  libxft-dev

  # compression lib required for ruby-build
  zlib1g
  # compression lib headers required for ruby-build
  zlib1g-dev
  # image processing
  imagemagick
  # required by nokogiri rubygem
  libxml2-dev
  libxslt1-dev
  # word diff lib
  dwdiff
  # curl
  curl
  libcurl4-openssl-dev

  # english dict lib
  wamerican

  # postgres database
  postgresql-9.4
  # postgres extensions
  postgresql-contrib-9.4
  # postgres driver lib
  libpq-dev

  # mysql server
  mysql-server
  # mysql driver lib
  libmysqlclient-dev

  # sqlite server
  sqlite3
  # sqlite driver lib
  libsqlite3-dev

  # key store server
  redis-server

  # nginx web server
  nginx-extras
  # nginx passenger ruby module
  passenger

  # javascript
  nodejs

  # ruby
  ruby2.3
  ruby2.3-dev

  # better shell
  zsh

  # terminal multiplexer
  tmux

  # phantomjs dependencies
  libfreetype6
  libfreetype6-dev
  libfontconfig1
  libfontconfig1-dev

  # nfs client
  nfs-common

  # chrome
  google-chrome-stable
  xvfb
)

apt -y -qq install ${packages[@]}

echo "Setting zsh as the default shell"
chsh -s /bin/zsh vagrant

echo "Setting up Postgres"

sudo -u postgres bash -c "psql -c \"CREATE USER vagrant WITH SUPERUSER PASSWORD 'vagrant';\""
sudo -u postgres bash -c "psql -c \"SELECT datname FROM pg_database WHERE encoding = pg_char_to_encoding('UTF8') AND datcollate = 'en_US.utf8' AND datctype = 'en_US.utf8'\""
sudo -u postgres bash -c "psql -c \"UPDATE pg_database SET encoding = pg_char_to_encoding('UTF8'), datcollate = 'en_US.utf8', datctype = 'en_US.utf8' WHERE datname = 'template1';\""

# allow incoming connections
echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "host    all             all             samenet          md5" >> /etc/postgresql/9.4/main/pg_hba.conf
service postgresql restart

echo "Setting up Passenger"
rm /etc/nginx/nginx.conf
cp /tmp/provision/nginx.conf /etc/nginx/nginx.conf
chmod 0644 /etc/nginx/nginx.conf

service nginx restart

echo "Setting up Xvfb"
cp /tmp/provision/Xvfb.service /etc/systemd/system/
chmod +x /etc/systemd/system/Xvfb.service
systemctl enable Xvfb.service
systemctl start Xvfb.service

echo "Setting up the Chrome driver"
cd /tmp
wget "https://chromedriver.storage.googleapis.com/2.29/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
mv chromedriver /usr/local/bin

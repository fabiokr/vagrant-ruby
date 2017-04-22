#!/bin/bash

function apt_ppa_repository_with_key {
  wget --quiet -O - "$2" | apt-key add -
  sh -c "echo '$3' >> $1"
}

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

UBUNTU_CODENAME=$(lsb_release --codename | cut -f2)

echo "Forward ssh"
echo "Defaults env_keep+=SSH_AUTH_SOCK" >> /etc/sudoers

echo "Setting up repositories..."

# ruby2.3
add-apt-repository --yes ppa:brightbox/ruby-ng

apt_ppa_repository_with_key "/etc/apt/sources.list.d/postgresql.list" "https://www.postgresql.org/media/keys/ACCC4CF8.asc" "deb http://apt.postgresql.org/pub/repos/apt/ $UBUNTU_CODENAME-pgdg main"
apt_ppa_repository_with_key "/etc/apt/sources.list.d/passenger.list" "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x561F9B9CAC40B2F7" "deb https://oss-binaries.phusionpassenger.com/apt/passenger $UBUNTU_CODENAME main"

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
  postgresql-9.5
  # postgres extensions
  postgresql-contrib-9.5
  # postgres driver lib
  libpq-dev
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
)

apt -y -qq install ${packages[@]}

echo "Setting zsh as the default shell"
chsh -s /bin/zsh vagrant

echo "Setting up Postgres"

sudo -u postgres bash -c "psql -c \"CREATE USER vagrant WITH SUPERUSER PASSWORD 'vagrant';\""
sudo -u postgres bash -c "psql -c \"SELECT datname FROM pg_database WHERE encoding = pg_char_to_encoding('UTF8') AND datcollate = 'en_US.utf8' AND datctype = 'en_US.utf8'\""
sudo -u postgres bash -c "psql -c \"UPDATE pg_database SET encoding = pg_char_to_encoding('UTF8'), datcollate = 'en_US.utf8', datctype = 'en_US.utf8' WHERE datname = 'template1';\""

echo "Setting up Passenger"
rm /etc/nginx/nginx.conf
cp /tmp/provision/nginx.conf /etc/nginx/nginx.conf
chmod 0644 /etc/nginx/nginx.conf

service nginx restart

echo "Setting up Phantomjs"
cd /tmp
PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
wget "https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2"
tar xvjf "$PHANTOM_JS.tar.bz2"
mv "$PHANTOM_JS" /usr/local/share
ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

#!/bin/bash

mkdir .bundle

cp /tmp/provision/zshrc ~/.zshrc
cp /tmp/provision/bundle ~/.bundle/config
cp /tmp/provision/gemrc ~/.gemrc

# install bundler
gem install --user-install bundler pry

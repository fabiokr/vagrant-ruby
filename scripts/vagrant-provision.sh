#!/bin/bash

mkdir .bundle

cp /tmp/provision/zshrc ~/.zshrc
cp /tmp/provision/bundle ~/.bundle/config
cp /tmp/provision/gemrc ~/.gemrc
cp /tmp/provision/gitconfig ~/.gitconfig
cp /tmp/provision/git-pretty-log ~/bin/git-pretty-log
cp /tmp/provision/git-sweep ~/bin/git-sweep

# install bundler
gem install --user-install bundler pry

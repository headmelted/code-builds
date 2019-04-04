#!/bin/bash
set -e;

echo "Removing old nvm for user if it exists";
rm -rf ~/.nvm;

echo "Cloning nvm for user";
git clone --depth 1 https://github.com/creationix/nvm.git ~/.nvm;

echo "Setting current owner as owner of ~/.nvm";
chown ${USER:=$(/usr/bin/id -run)}:$USER -R ~/.nvm;

echo "Running NVM script";
source ~/.nvm/nvm.sh;

echo "Setting up NVM";
nvm install 8.12.0;
nvm use 8.12.0;
nvm alias default 8.12.0;
  
echo "Setting python binding";
npm config set python `which python`;

echo "Installing npm dependencies";
npm install -g gulp yarn --unsafe-perm;

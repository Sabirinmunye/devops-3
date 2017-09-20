#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
# sudo apt-get upgrade -y

sudo apt-get install nginx -y
sudo rm /etc/nginx/sites-available/default
sudo cp /home/ubuntu/app/environment/nginx.default /etc/nginx/sites-available/default
sudo useradd --home /home/ubuntu/app app
sudo chown -R app:app app
sudo service nginx restart
curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs -y
sudo npm install -g pm2




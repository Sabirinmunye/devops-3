sudo service mongod start -y
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y mongodb-org
sudo rm /etc/mongod.conf
sudo cp /home/ubuntu/app/environment/mongod.conf /etc/mongod.conf
sudo service mongod restart 
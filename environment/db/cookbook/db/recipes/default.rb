#
# Cookbook:: db
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


apt_repository 'mongodb-org' do 
  uri "http://repo.mongodb.org/apt/ubuntu"
  distribution "xenial/mongodb-org/3.2"
  components ["multiverse"]
  keyserver "hkp://keyserver.ubuntu.com:80"
  key "EA312927"
end

apt_update

package 'mongodb'


template '/etc/mongod.conf' do
	source 'mongo.conf.erb'
	
end

template '/lib/systemd/system/mongod.service' do
	source 'mongo.service.erb'
	action :create
end

service 'mongod' do 
	supports status: true, restart: true
	action [:enable, :start]
end

#!/bin/bash
echo "Starting App"
export DB_HOST=mongodb://11.5.2.6/posts
cd /home/ubuntu/app
npm install
node app.js
pm2 start app.js

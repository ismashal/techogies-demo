#!/bin/bash -v

set -e -x

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

sudo apt-get update
sudo apt-get install unzip kubectl git default-jdk -y
sudo apt-get install jenkins nginx-full -y 

curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install nodejs npm -y
sudo ln -s /usr/bin/nodejs /usr/bin/node

sudo rm /etc/nginx/sites-available/default
echo "upstream jenkins{
    server 127.0.0.1:8080;
}
server{
    listen      80;
    server_name jenkins.devops.com;

    access_log  /var/log/nginx/jenkins.access.log;
    error_log   /var/log/nginx/jenkins.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://jenkins;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}" > /etc/nginx/sites-available/default

sudo nginx -t
sudo service nginx restart
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
#!/bin/bash
yum -y update
yum -y install httpd
sudo yum -y install git
cd /var/www/html
sudo git config --global github.user nar3kjan
sudo git config --global github.token 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
sudo git clone https://github.com/nar3kjan/appforjenkins.git
sudo mv /var/www/html/appforjenkins/* /var/www/html
sudo rm -r /var/www/html/appforjenkins 
sudo service httpd start
chkconfig httpd on
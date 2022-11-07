#!/bin/bash
yum -y update
yum -y install httpd

#sudo yum -y install git
#cd /var/www/html
#sudo git config --global github.user nar3kjan
#sudo git config --global github.token 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
#sudo git clone https://github.com/nar3kjan/appforjenkins.git
#sudo mv /var/www/html/appforjenkins/* /var/www/html
#sudo rm -r /var/www/html/appforjenkins

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Power of Terraform <font color="red"> v0.12</font></h2><br><p>
<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>
<font color="magenta">
<b>Version 3.0</b>
</body>
</html>
EOF


sudo service httpd start
chkconfig httpd on

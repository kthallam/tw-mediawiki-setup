#!/bin/bash
set -x
set -e
DIR="/mnt/mediawiki/mediawiki-1.36.1"
amazon-linux-extras enable php7.4
yum install -y php php-mysqlnd php-gd php-xml mariadb-server mariadb php-mbstring php-json httpd php-intl
mkdir /mnt/mediawiki
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}:/ /mnt/mediawiki
if [ -d "$DIR" ]; then
  ln -s /mnt/mediawiki/mediawiki-1.36.1 /var/www/mediawiki
  echo "Creting Soft link"
else
 wget https://releases.wikimedia.org/mediawiki/1.36/mediawiki-1.36.1.tar.gz --directory-prefix=/tmp/
 cd /mnt/mediawiki/
 tar -zxf /tmp/mediawiki-1.36.1.tar.gz
 ln -s /mnt/mediawiki/mediawiki-1.36.1 /var/www/mediawiki
fi
chown -R apache:apache /var/www/mediawiki
sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www/mediawiki"|g' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www">|<Directory "/var/www/mediawiki">|g' /etc/httpd/conf/httpd.conf
sed -i 's|DirectoryIndex index.html|DirectoryIndex index.html index.html.var index.php|g' /etc/httpd/conf/httpd.conf
systemctl enable httpd
systemctl start httpd

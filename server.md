FTP
apt-get install pure-ftpd -y
systemctl status pure-ftpd

openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -days 365
nano /etc/pure-ftpd/pure-ftpd.conf

TLS                          2
TLSCipherSuite               HIGH:MEDIUM:+TLSv1:!SSLv2:!SSLv3
CertFile                     /etc/ssl/private/pure-ftpd.pem

sudo adduser ftpuser

mkdir /var/www/api.creator.az/

sudo usermod -d /var/www ftpuser

sudo chown ftpuser:ftpuser /var/www/html

sudo ufw allow OpenSSH

sudo ufw allow 20/tcp

sudo ufw allow 21/tcp

sudo ufw allow 40000:50000/tcp

sudo ufw allow 990/tcp

systemctl restart pure-ftpd


apache2

sudo apt install apache2

systemctl start apache2

systemctl enable apache2

systemctl status apache2

for svc in ssh http https
do 
ufw allow $svc
done

sudo ufw enable





sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt -y install libapache2-mod-php php7.4 php-pear unzip zip git
sudo apt -y install php7.4-{bcmath,bz2,intl,gd,mbstring,mysql,zip,common,common,xml,opcache,tokenizer,json,bcmath,zip,curl,mysql}

cd /etc/php/7.4/
vim apache2/php.ini

cgi.fix_pathinfo=0 

systemctl restart apache2

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

composer --version

useradd -m -s /bin/bash hakase
passwd hakase

su - hakase

sudo chgrp -R www-data /home/hakase/blog
sudo chmod -R 775 /home/hakase/blog/storage

sudo chown -R www-data:www-data /var/www/blog
sudo chmod -R 775 /var/www/blog/storage

cd /etc/apache2/sites-available/
vim laravel.conf

<VirtualHost *:80>
    ServerName hakase-labs.io

    ServerAdmin admin@hakase-labs.io
    DocumentRoot /home/hakase/blog/public

    <Directory /home/hakase/blog>
    Options Indexes MultiViews
    AllowOverride None
    Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

sudo a2enmod rewrite
sudo a2ensite laravel.conf

apachectl configtest
systemctl restart apache2

apt install -y certbot

certbot certificates

certbot certonly --webroot

certbot certonly --webroot --webroot-path /var/www/html --agree-tos -m your_email@example.com -d www.example.com

ss -lntp 'sport = 80'

certbot certonly --standalone

Once the certificate is issued, you will need to configure your web server manually. The relevant files can be found in /etc/letsencrypt/live/your_domain.

apt install -y python-certbot-apache
certbot run --apache

sudo apt install mysql-server

sudo systemctl status mysql

sudo mysql_secure_installation

sudo systemctl stop mysql

sudo systemctl start mysql

sudo systemctl restart mysql

sudo systemctl status mysql

mysql -u root -p

CREATE DATABASE mydb;
CREATE USER 'myuser'@'localhost' IDENTIFIED by 'Pa$$w0rd';
GRANT ALL on mydb.* to 'myuser'@'localhost';
FLUSH PRIVILEGES;

sudo apt install apache2 wget unzip
sudo apt install php php-zip php-json php-mbstring php-mysql

systemctl enable apache2
systemctl start apache2

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.3/phpMyAdmin-5.0.3-all-languages.zip
unzip phpMyAdmin-5.0.3-all-languages.zip
mv phpMyAdmin-5.0.3-all-languages /usr/share/phpmyadmin

mkdir /usr/share/phpmyadmin/tmp
chown -R www-data:www-data /usr/share/phpmyadmin
chmod 777 /usr/share/phpmyadmin/tmp

sudo vi /etc/apache/conf-available/phpmyadmin.conf

Alias /phpmyadmin /usr/share/phpmyadmin
Alias /phpMyAdmin /usr/share/phpmyadmin
 
<Directory /usr/share/phpmyadmin/>
   AddDefaultCharset UTF-8
   <IfModule mod_authz_core.c>
      <RequireAny>
      Require all granted
     </RequireAny>
   </IfModule>
</Directory>
 
<Directory /usr/share/phpmyadmin/setup/>
   <IfModule mod_authz_core.c>
     <RequireAny>
       Require all granted
     </RequireAny>
   </IfModule>
</Directory>

sudo a2enconf phpmyadmin
sudo systemctl restart apache2

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload


































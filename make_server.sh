#!/bin/bash
echo "Serverin yaradılması üçün lazımı programların yüklənilməsi başladılır..."
sleep 5

echo "Sistem yeniləmələri yüklənir..."
sleep 5

sudo apt update -y
sudo apt upgrade -y

echo "Sistem gərəksinimləri yüklənir..."
sleep 5

sudo apt install apache2 wget unzip zip php php-zip libonig5 libzip5 php-json php-mbstring php-mysql -y

read -p 'MySQL Server yüklənilsin? (y/n)'
if [ $REPLY=="y" ]
then
sudo apt install mysql-server -y
fi

sudo systemctl status mysql

echo "MySQL konfiqrasiya edilir..."

sleep 5

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

# Predicate that returns exit status 0 if the database root password
# is set, a nonzero exit status otherwise.
is_mysql_root_password_set() {
  ! mysqladmin --user=root status > /dev/null 2>&1
}

# Predicate that returns exit status 0 if the mysql(1) command is available,
# nonzero exit status otherwise.
is_mysql_command_available() {
  which mysql > /dev/null 2>&1
}

#{{{ Variables
db_root_password="P@ssw0rd_777"
#}}}

# Script proper

if ! is_mysql_command_available; then
  echo "The MySQL/MariaDB client mysql(1) is not installed."
  exit 1
fi

if is_mysql_root_password_set; then
  echo "Database root password already set"
  exit 0
fi

mysql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
   
CREATE DATABASE main
CREATE USER 'eldar'@'%' IDENTIFIED by 'P@ssw0rd_777';
 
GRANT ALL on *.* to 'eldar'@'%';

FLUSH PRIVILEGES;
_EOF_

sudo systemctl stop mysql
sudo systemctl start mysql
sudo systemctl restart mysql
sudo systemctl status mysql
fi





read -p 'phpmyadmin yüklənilsin? (y/n)'

if [ $REPLY=="y" ]
then

systemctl enable apache2
systemctl start apache2

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.3/phpMyAdmin-5.0.3-all-languages.zip
unzip phpMyAdmin-5.0.3-all-languages.zip
mv phpMyAdmin-5.0.3-all-languages /usr/share/phpmyadmin
mkdir /usr/share/phpmyadmin/tmp
chown -R www-data:www-data /usr/share/phpmyadmin
chmod 777 /usr/share/phpmyadmin/tmp
echo "Alias /phpmyadmin /usr/share/phpmyadmin
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
</Directory>" > /etc/apache/conf-available/phpmyadmin.conf

sudo a2enconf phpmyadmin
sudo systemctl restart apache2
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

if ! echo -e /etc/apache/conf-available/phpmyadmin.conf; then
echo "phpmyadmin Yüklənə bilmədi !"
else
echo "phpmyadmin Yükləni !"
fi
fi
read -p 'FTP Server yüklənilsin? (y/n)'

if [ $REPLY=="y" ]
then

apt-get install vsftpd
sudo ufw allow OpenSSH
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp
sudo ufw allow 990/tcp
sudo ufw enable
sudo ufw status

useradd -m eldar -g ftpaccess -s /var/www
passwd eldar
sudo usermod -d /var/www eldar
chown eldar /var/www
sudo chown eldar:eldar /var/www/html
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.bak
echo "listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=ftp
force_dot_files=YES
pasv_min_port=40000
pasv_max_port=50000" > /etc/vsftpd.conf
sudo systemctl restart vsftpd
echo "tamamlandi"
exit

fi

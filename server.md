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

systemctl restart pure-ftpd

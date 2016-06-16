#!/bin/bash

source /vagrant/vars.sh
echo -e "192.168.100.51\t${HOST_SQL} ${HOST_SQL}.${DOMAIN}" | sudo tee --append /etc/hosts

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove

# useful / dependencies
sudo apt-get -y install htop unzip
sudo apt-get -y install postgresql

# allow remote access for postgres
sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.3/main/postgresql.conf
echo -e "host    all     all     0.0.0.0/0       md5" | sudo tee --append /etc/postgresql/9.3/main/pg_hba.conf
sudo service postgresql restart

# install postfix
# see https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04
debconf-set-selections <<< "postfix postfix/mailname string ${HOST_SQL}.${DOMAIN}"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get -y install mailutils
sudo sed -i -e 's/inet_interfaces = all/inet_interfaces = loopback-only/g' /etc/postfix/main.cf
echo -e "root: ${ADMIN_EMAIL}" | sudo tee --append /etc/aliases
sudo service postfix restart

# Create XNAT's database user.
sudo -u postgres createuser -U postgres -S -D -R ${POSTGRESQL_XNAT_USER}
sudo -u postgres psql -U postgres -c "ALTER USER ${POSTGRESQL_XNAT_USER} WITH PASSWORD '${POSTGRESQL_XNAT_PASSWD}'"
sudo -u postgres createdb -U postgres -O ${POSTGRESQL_XNAT_USER} ${POSTGRESQL_XNAT_DB}

echo "Postgresql configured!"

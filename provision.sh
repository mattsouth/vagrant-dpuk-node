#!/bin/bash

source /vagrant/vars.sh
echo -e "192.168.50.50\t${HOST} ${HOST}.${DOMAIN}" | sudo tee --append /etc/hosts

# # Install dependencies: configure NeuroDebian, update and upgrade the VM, then install PostgreSQL, OpenJDK 7, Tomcat 7, and nginx.
wget -O- http://neuro.debian.net/lists/trusty.us-tn.libre | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y autoremove

# useful / dependencies
sudo apt-get -y install htop unzip
sudo apt-get -y install openjdk-7-jdk
sudo apt-get -y install tomcat7
sudo apt-get -y install nginx
sudo apt-get -y install postgresql

# install postfix
# see https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04
debconf-set-selections <<< "postfix postfix/mailname string ${HOST}.${DOMAIN}"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get -y install mailutils
sudo sed -i -e 's/inet_interfaces = all/inet_interfaces = loopback-only/g' /etc/postfix/main.cf
echo -e "root: ${ADMIN_EMAIL}" | sudo tee --append /etc/aliases
sudo service postfix restart

# Create XNAT user
sudo useradd -g users -d /home/xnat -s /bin/bash xnat
sudo groupadd xnat
sudo usermod -a -G xnat xnat
sudo mkdir /home/xnat
sudo chown -R xnat.xnat /home/xnat

# Stop these services so that we can configure them later.
sudo service tomcat7 stop
sudo service nginx stop

# Download XNAT and the pipeline installer.
sudo mkdir -p /data/xnat/src
chmod -R 777 /data
cd /data/xnat/src
if [ -f /vagrant/${XNAT}.tar.gz ]; then
    sudo cp /vagrant/${XNAT}.tar.gz .
else
    sudo curl -O https://info.dpuk.org/wp-content/uploads/2016/02/xnat_builder_1_6dev_dpuk_node.tar.gz
    sudo cp ${XNAT}.tar.gz /vagrant/.
fi
tar -zxvf ${XNAT}.tar.gz
[[ ! -d /data/xnat/src/${XNAT} && -d /data/xnat/src/xnat ]] && { mv /data/xnat/src/xnat /data/xnat/src/${XNAT}; }
cat /vagrant/build.properties.tmpl | sed "s/@HOST@/${HOST}/g" | sed "s/@DOMAIN@/${DOMAIN}/g" | tee /data/xnat/src/${XNAT}/build.properties
cp /vagrant/project.properties /data/xnat/src/${XNAT}/project.properties

if [ -f /vagrant/${PIPELINE_INST}.tar.gz ]; then
    sudo cp /vagrant/${PIPELINE_INST}.tar.gz .
else
    sudo curl -O ftp://ftp.nrg.wustl.edu/pub/xnat/${PIPELINE_INST}.tar.gz
    sudo cp ${PIPELINE_INST}.tar.gz /vagrant/.
fi
tar -zxvf ${PIPELINE_INST}.tar.gz
[[ ! -d /data/xnat/src/${PIPELINE_INST} && -d /data/xnat/src/pipeline-installer ]] && { mv /data/xnat/src/pipeline-installer /data/xnat/src/${PIPELINE_INST}; }

rm /data/xnat/src/*.tar.gz

# Create data directories
mkdir /data/xnat/archive
mkdir /data/xnat/build
mkdir /data/xnat/cache
mkdir /data/xnat/ftp
mkdir /data/xnat/prearchive
mkdir -p /data/xnat/modules/webapp
cp /vagrant/modules/* /data/xnat/modules/webapp/.
cat /vagrant/services.properties | sed "s/@HOST@/${HOST}/g" | sed "s/@DOMAIN@/${DOMAIN}/g" | sed "s/@LDAP_OU@/${LDAP_OU}/g" | sed "s/@LDAP_NODE_UID@/${LDAP_NODE_UID}/g" | tee /data/xnat/src/${XNAT}/plugin-resources/conf/services.properties

sudo chown -R xnat.xnat /data
sudo chmod -R 755 /data

# Make XNAT user the Tomcat owner.
sudo cp /var/lib/tomcat7/conf/server.xml /var/lib/tomcat7/conf/server.xml.bak
sudo cp /vagrant/server.xml /var/lib/tomcat7/conf/server.xml
sudo mkdir /var/lib/tomcat7/empty
sudo chown -RL xnat.xnat /var/lib/tomcat7
sudo chown -Rh xnat.xnat /var/lib/tomcat7
sudo cp /etc/default/tomcat7 /etc/default/tomcat7.bak
cat /vagrant/tomcat7.tmpl | sed "s#@JAVA_PATH@#${JAVA_PATH}#g" | sudo tee /etc/default/tomcat7

# Configure nginx to proxy Tomcat.
cat /vagrant/xnatdev.tmpl | sed "s/@HOST@/${HOST}/g" | sed "s/@DOMAIN@/${DOMAIN}/g" | sudo tee /etc/nginx/sites-available/${HOST}
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/${HOST} /etc/nginx/sites-enabled/${HOST}

# Create XNAT's database user.
sudo -u postgres createuser -U postgres -S -D -R xnat
sudo -u postgres psql -U postgres -c "ALTER USER xnat WITH PASSWORD 'xnat'"
sudo -u postgres createdb -U postgres -O xnat xnat

# xnat installation
cd /data/xnat/src/${XNAT}
sudo su xnat -c "echo 'export JAVA_HOME=${JAVA_PATH}' >> /home/xnat/.bashrc"
sudo su xnat -c "echo 'export PATH=\${PATH}:/data/xnat/src/${XNAT}/bin' >> /home/xnat/.bashrc"
sudo su xnat -c "source ~/.bashrc && bin/setup.sh -Ddeploy=true"
cd deployments/xnat
sudo -u xnat psql -d xnat -f sql/xnat.sql -U xnat
sudo su xnat -c "source ~/.bashrc && StoreXML -l security/security.xml -allowDataDeletion true"
sudo su xnat -c "source ~/.bashrc && StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true"

sudo rm -r /var/log/nginx/* /var/log/tomcat7/*

sudo service nginx start
sudo service tomcat7 start

echo "Almost done! Provisioning is complete, however"
echo "there are a few manual tasks that must still be completed..."
echo "1. Set the XNAT name, we suggest DPUK-[SITE], e.g. DPUK-OXFORD"
echo "2. Configure the Datafreeze properties"
echo "3. Configure DPUK datatypes in XNAT"
echo "See https://info.dpuk.org/testing/post-install-steps for further instructions"

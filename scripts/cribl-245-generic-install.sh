#!/bin/bash

#############################################################################################################
##                                                                                                         ##
## This is a cribl startup script. Is mainly used to check for current cribl installation on Linux OS and  ##
## peform preflight checks for different pre-requisites and pefrom cribl installation                      ##
##                                                                                                         ##
#############################################################################################################

# Checking Pre-requisites

CHECK_GIT=`which git | grep "/bin/git" | wc -l`
CHECK_WGET=`which wget | grep "/bin/wget" | wc -l`
# Global Variables

# Prepare Enviroment

sudo mkdir -p /opt/Apps/

# Check and Install Git if not installed
if ! [[ $CHECK_GIT -eq 1 ]]; then
sudo yum -y install git
fi

# Check and Install wget 
if ! [[ $CHECK_WGET -eq 1 ]]; then
sudo yum -y install wget
fi


# Create Cribl User and Group

sudo groupadd cribl
sudo useradd cribl --comment "Cribl User" --system --create-home --shell /bin/bash -g cribl
sudo usermod --expiredate "" cribl

sudo echo "cribl ALL=(root) NOPASSWD: /usr/bin/systemctl start Cribl.service, /usr/bin/systemctl stop Cribl.service, /usr/bin/systemctl restart Cribl.service, /usr/bin/systemctl status Cribl.service, /opt/SP/cribl/current/bin/cribl enable boot-start -systemd-managed 1 -user cribladm" >> /etc/sudoers

sudo echo "cribl soft nofile 65536" >> /etc/security/limits.d/25-cribl.conf
sudo echo "cribl hard nofile 65536" >> /etc/security/limits.d/25-cribl.conf

# Download and Install Cribl Version ;; Hardcoded for 2.4.5 for now
sudo wget -O /tmp/cribl-2.4.5-fa7a97a7-linux-x64.tgz 'https://cdn.cribl.io/dl/2.4.5/cribl-2.4.5-fa7a97a7-linux-x64.tgz'
sudo tar xvzf /tmp/cribl-2.4.5-fa7a97a7-linux-x64.tgz -C /opt/Apps/
sudo mv /opt/Apps/cribl /opt/Apps/cribl-2.4.5
sudo ln -s /opt/Apps/cribl-2.4.5 /opt/Apps/current
## Change Owner to cribladm user
sudo chown -R cribl:cribl /opt/Apps
# Start Cribl to create missing directories first
sudo su - cribl -c '/opt/Apps/current/bin/cribl start'
# ## Configure Cribl to run as a Master (Initial Version for static config)
# cd ${CRIBL_HOME}/current/local/
# mkdir _system 
# cat <<-EOF > ${CRIBL_HOME}/current/local/_system/instance.yml
# distributed:
#   mode: master
#   master:
#     host: <IP or 0.0.0.0>
#     port: 4200
#     tls:
#       disabled: true
#     ipWhitelistRegex: /.*/
#     authToken: <auth token>
#     enabledWorkerRemoteAccess: false
#     compression: none
#     connectionTimeout: 5000
#     writeTimeout: 10000
# EOF
# # Restart Cribl to make it Master
# su - cribl -c '/opt/Apps/current/bin/cribl restart'

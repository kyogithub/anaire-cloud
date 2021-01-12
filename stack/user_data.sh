#!/bin/bash
LOG_LOCATION=/home/ubuntu
exec > >(tee -i $LOG_LOCATION/userdata.txt)
exec 2>&1
sudo apt update && sudo apt install -y jq unzip git

#====================VARIABLES==============================
export PUBLIC_IP=yourvmIPorDNS
export GRAFANA_ADMIN_PASSWORD="your_password"
#===========================================================

#==============Initialize /data if needed===================
#Ensure there is a directory created for the applications persistent data
for application in prometheus pushgateway grafana mosquitto
do
  if [ ! -d /data/$application ]; then 
    sudo mkdir -p /data/$application
    sudo chown -R ubuntu:ubuntu /data/$application
    sudo chmod o+w /data/$application
  fi
done
#===========================================================

#===============Install K8s and helm3=======================
#Create all in one kubernetes
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ubuntu
sudo microk8s.enable dns
sudo microk8s.enable helm3
echo "alias sudo='sudo '" >> /home/ubuntu/.bashrc
echo "alias kubectl='microk8s.kubectl'" >> /home/ubuntu/.bashrc
echo "alias helm='microk8s.helm3'" >> /home/ubuntu/.bashrc
#===========================================================

#================Install anaire cloud stack=================
cd /home/ubuntu/
git clone https://github.com/anaireorg/anaire-cloud.git
sudo microk8s.helm3 install --set publicIP=$PUBLIC_IP --set grafanaAdminPass=$GRAFANA_ADMIN_PASSWORD anairestack anaire-cloud/stack/anairecloud
#===========================================================
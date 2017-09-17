#!/bin/bash

curl -L https://bootstrap.saltstack.com -o bootstrap_salt.sh
sudo sh bootstrap_salt.sh
rm bootstrap_salt.sh

sudo tee /etc/salt/minion << EOF
file_client: local
file_roots:
  base:
    - /srv/salt
    - /srv/formulas/docker-formula-master
    - /srv/files
EOF

sudo systemctl restart salt-minion

# Init states
sudo mkdir -p /srv/salt
sudo cp ./salt/* /srv/salt

# Init files
sudo mkdir -p /srv/files
sudo cp ./files/* /srv/files

# Init Pillar
sudo mkdir -p /srv/pillar
sudo cp ./pillar/* /srv/pillar

# Init Docker Compose stuff
sudo mkdir -p /opt/media-compose
sudo chown colin:colin /opt/media-compose
cp docker-compose.yml .env /opt/media-compose

# Init all the formulas
sudo mkdir -p /srv/formulas
for formula in docker; do
    wget https://github.com/saltstack-formulas/${formula}-formula/archive/master.tar.gz -O ${formula}-formula.tar.gz
    sudo tar -xf ${formula}-formula.tar.gz -C /srv/formulas
    rm ${formula}-formula.tar.gz
done

sudo salt-call --local state.highstate

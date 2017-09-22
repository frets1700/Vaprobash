#!/usr/bin/env bash

if [[ -z $1 ]]; then
        KIBANA_VERSION="5.2.2"
else
        KIBANA_VERSION=$1
fi

echo ">>> Installing Kibana $KIBANA_VERSION"

sudo mkdir -p /opt/kibana

comp=$(awk 'BEGIN{ print "'$KIBANA_VERSION'"<"'4.6.0'" }')

if [ "$comp" -eq 1 ]; then
    wget --quiet https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz
    sudo tar xvf kibana-$KIBANA_VERSION-linux-x64.tar.gz -C /opt/kibana --strip-components=1
    rm kibana-$KIBANA_VERSION-linux-x86_64.tar.gz
else
    wget --quiet https://artifacts.elastic.co/downloads/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz
    sudo tar xvf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz -C /opt/kibana --strip-components=1
    rm kibana-$KIBANA_VERSION-linux-x86_64.tar.gz
fi

# Configure to start up Kibana automatically
cd /etc/init.d
sudo wget --quiet https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/bce61d85643c2dcdfbc2728c55a41dab444dca20/kibana4

sudo chmod +x /etc/init.d/kibana4
sudo update-rc.d kibana4 defaults 95 10
sudo service kibana4 start

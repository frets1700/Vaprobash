#!/usr/bin/env bash

echo ">>> Installing Elasticsearch"

# Set some variables
ELASTICSEARCH_VERSION=$1 # Check https://www.elastic.co/downloads/elasticsearch for latest version

comp=$(awk 'BEGIN{ print "'$ELASTICSEARCH_VERSION'"<"'5.1.2'" }')

# Install prerequisite: Java
# -qq implies -y --force-yes
if [ "$comp" -eq 1 ]; then
	sudo apt-get update
    sudo apt-get install -qq openjdk-7-jre-headless
    wget --quiet https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.deb
else
	sudo add-apt-repository -y ppa:openjdk-r/ppa
	sudo apt-get update
	sudo apt-get -y install openjdk-8-jdk openjdk-8-jre
	wget --quiet https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.deb
fi

sudo dpkg -i elasticsearch-$ELASTICSEARCH_VERSION.deb
rm elasticsearch-$ELASTICSEARCH_VERSION.deb

# Configure Elasticsearch for development purposes (1 shard/no replicas, don't allow it to swap at all if it can run without swapping)
sudo sed -i "s/# index.number_of_shards: 1/index.number_of_shards: 1/" /etc/elasticsearch/elasticsearch.yml
sudo sed -i "s/# index.number_of_replicas: 0/index.number_of_replicas: 0/" /etc/elasticsearch/elasticsearch.yml
sudo sed -i "s/# bootstrap.mlockall: true/bootstrap.mlockall: true/" /etc/elasticsearch/elasticsearch.yml

# either of the next two lines is needed to be able to access "localhost:9200" from the host os
sudo echo "network.bind_host: 0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# enable cors (to be able to use Sense)
# sudo echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "http.cors.allow-origin: /https?:\/\/localhost(:[0-9]+)?/" >> /etc/elasticsearch/elasticsearch.yml

# enable dynamic scripting
sudo echo "script.inline: on" >> /etc/elasticsearch/elasticsearch.yml

sudo service elasticsearch restart

# Configure to start up Elasticsearch automatically
sudo update-rc.d elasticsearch defaults 95 10

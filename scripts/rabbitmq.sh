#!/usr/bin/env bash

echo ">>> talling RabbitMQ"

apt-get -y install erlang-nox
wget http://www.rabbitmq.com/rabbitmq-release-signing-key.asc
apt-key add rabbitmq-release-signing-key.asc
echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
apt-get update
apt-get install -y rabbitmq-server
rabbitmq-plugins enable rabbitmq_management

# Allow guests to login thru rabbitmq management
echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config
service rabbitmq-server restart

rabbitmqctl add_user $1 $2
rabbitmqctl set_permissions -p / $1 ".*" ".*" ".*"

#!/bin/bash

export HOST_IP=`hostname -I | cut -d' ' -f 1`

echo "Setting stack IP to $HOST_IP"



docker stack deploy -c docker-stack.yml kafka-stack

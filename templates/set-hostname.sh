#!/bin/env bash

URL="http://169.254.169.254/latest"
TOKEN=`curl -s -X PUT "$URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
DOMAIN=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $URL/meta-data/tags/instance/Domain`
HOSTNAME=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $URL/meta-data/tags/instance/Hostname`
hostnamectl set-hostname $HOSTNAME
sed -r -i "s/^search .+/search $DOMAIN/g" /etc/resolv.conf

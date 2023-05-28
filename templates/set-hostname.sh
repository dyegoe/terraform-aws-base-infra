#!/bin/env bash

URL="http://169.254.169.254/latest"
TOKEN=`curl -s -X PUT "$URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $URL/meta-data/tags/instance/Instance`
PROJECT=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $URL/meta-data/tags/instance/Project`
DOMAIN=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $URL/meta-data/tags/instance/ZoneDomain`
hostnamectl set-hostname $INSTANCE.$PROJECT.$DOMAIN

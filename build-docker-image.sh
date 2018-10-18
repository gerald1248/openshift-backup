#!/bin/sh

# fetch params first
. ./exports
GROUP=gerald1248
NAME=openshift-backup
TAG=latest

docker build -t ${NAME}:${TAG} . 
docker tag ${NAME}:${TAG} ${GROUP}/${NAME}:${TAG}
docker push ${GROUP}/${NAME}:${TAG}

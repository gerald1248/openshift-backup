#!/bin/bash

OPENSHIFT_BACKUP_VERSION=latest
GITHUB_NAME=gerald1248

for dependency in jq curl head unzip; do
  if [ -z $(which $dependency) ]; then
    echo "Missing dependency '$dependency'"
    exit 1
  fi
done

docker build -t openshift-backup:${OPENSHIFT_BACKUP_VERSION} .
docker tag openshift-backup:${OPENSHIFT_BACKUP_VERSION} ${GITHUB_NAME}/openshift-backup:${OPENSHIFT_BACKUP_VERSION}
docker push ${GITHUB_NAME}/openshift-backup:${OPENSHIFT_BACKUP_VERSION}

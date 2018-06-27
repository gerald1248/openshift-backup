#!/bin/bash

OPENSHIFT_BACKUP_VERSION=latest
OC_VERSION=latest
DOWNLOAD_ALWAYS=0

for dependency in jq curl head unzip; do
  if [ -z $(which $dependency) ]; then
    echo "Missing dependency '$dependency'"
    exit 1
  fi
done

if [ ! -d downloads/ ]; then
  mkdir downloads
fi

if [ ! -f downloads/oc ] || [ $DOWNLOAD_ALWAYS -gt 0 ]; then
  OC_URL=`curl -s https://api.github.com/repos/openshift/origin/releases/${OC_VERSION} | jq -cr '.assets[] | select( .name | contains(".tar.gz"))' | head -n1 | jq -rc '.browser_download_url'`
  if [ -z $OC_URL ]; then
    echo "Can't determine oc download URL"
    exit 1
  fi
  echo "Downloading $OC_URL"
  curl -L $OC_URL -o downloads/oc.tar.gz && tar -xf downloads/oc.tar.gz -C downloads/ && cp downloads/openshift-origin-client-tools-*/oc downloads/
fi

for script in project_export.sh project_import.sh; do
  if [ ! -f downloads/${script} ] || [ $DOWNLOAD_ALWAYS -gt 0 ]; then
	  SCRIPT_URL="https://raw.githubusercontent.com/openshift/openshift-ansible-contrib/master/reference-architecture/day2ops/scripts/${script}"
	  curl -L $SCRIPT_URL -o downloads/${script}
  fi
done

docker build -t openshift-backup:$OPENSHIFT_BACKUP_VERSION .

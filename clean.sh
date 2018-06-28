#!/bin/sh

# fetch OPENSHIFT_BACKUP_NAMESPACE and OPENSHIFT_BACKUP_NAME first
. ./exports

oc delete --ignore-not-found project/${OPENSHIFT_BACKUP_NAMESPACE}
oc delete --ignore-not-found clusterrolebinding/${OPENSHIFT_BACKUP_NAME}-cluster-reader
oc delete --ignore-not-found clusterrolebinding/${OPENSHIFT_BACKUP_NAME}-secret-reader
oc delete --ignore-not-found clusterrole/${OPENSHIFT_BACKUP_NAME}-secret-reader

for i in {1..20}; do
  echo "[${i}] Project termination ongoing..."
	if [ $(oc get projects | grep -e \\b${OPENSHIFT_BACKUP_NAMESPACE}\\b | wc -l) -eq "0" ]; then
	  echo "Done"
	  break;
	fi
	sleep 5
done

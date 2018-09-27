#!/bin/sh

# fetch OPENSHIFT_BACKUP_NAMESPACE and OPENSHIFT_BACKUP_NAME first
. ./exports

oc delete --ignore-not-found "project/${OPENSHIFT_BACKUP_NAMESPACE}"
oc delete --ignore-not-found "clusterrolebinding/${OPENSHIFT_BACKUP_NAME}-cluster-reader"
if ${BACKUP_SECRETS}; then
    oc delete --ignore-not-found "clusterrolebinding/${OPENSHIFT_BACKUP_NAME}-secret-reader"
    oc delete --ignore-not-found "clusterrole/${OPENSHIFT_BACKUP_NAME}-secret-reader"
fi

for i in $(seq 1 20); do
    echo "[${i}] Project termination ongoing..."
    if [ "$(oc get projects | grep -ec "\\b${OPENSHIFT_BACKUP_NAMESPACE}\\b")" -eq "0" ]; then
        echo "Done"
        break;
    fi
    sleep 5
done

#!/bin/sh

# export OPENSHIFT_BACKUP_*
. ./exports

# stop if project exists
oc export project/${OPENSHIFT_BACKUP_NAMESPACE} >/dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "project ${OPENSHIFT_BACKUP_NAMESPACE} found; run 'make clean' first"
	exit 1
fi

oc new-project ${OPENSHIFT_BACKUP_NAMESPACE} --display-name="OpenShift cluster backup" >/dev/null

oc new-app --file=openshift/template.yml --param='NAME'="${OPENSHIFT_BACKUP_NAME}" --param='NAMESPACE'="${OPENSHIFT_BACKUP_NAMESPACE}" --param='CAPACITY'="${OPENSHIFT_BACKUP_CAPACITY}"

oc logs -f dc/${OPENSHIFT_BACKUP_NAME}

oc get po -o wide

#!/bin/sh

# export OPENSHIFT_BACKUP_*
. ./exports

# stop if project exists
oc export "project/${OPENSHIFT_BACKUP_NAMESPACE}" >/dev/null 2>&1
# shellcheck disable=SC2181
if [ "$?" -eq "0" ]; then
    echo "project ${OPENSHIFT_BACKUP_NAMESPACE} found; run 'make clean' first"
    exit 1
fi

oc new-project "${OPENSHIFT_BACKUP_NAMESPACE}" --display-name="OpenShift cluster backup" >/dev/null

TEMPLATE_FILE="openshift/template.yml"
if [ ! ${BACKUP_SECRETS} ]; then
    TEMPLATE_FILE="openshift/template-no-secret.yml"
fi

oc process -f "${TEMPLATE_FILE}" --param='NAME'="${OPENSHIFT_BACKUP_NAME}" --param='NAMESPACE'="${OPENSHIFT_BACKUP_NAMESPACE}" --param='CAPACITY'="${OPENSHIFT_BACKUP_CAPACITY}" --param='SCHEDULE'="${OPENSHIFT_BACKUP_SCHEDULE}" | oc apply -f -

oc get all

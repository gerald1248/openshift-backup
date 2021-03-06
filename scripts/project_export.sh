#!/bin/bash
# OpenShift namespaced objects:
# oc get --raw /oapi/v1/ |  python -c 'import json,sys ; resources = "\n".join([o["name"] for o in json.load(sys.stdin)["resources"] if o["namespaced"] and "create" in o["verbs"] and "delete" in o["verbs"] ]) ; print(resources)'
# Kubernetes namespaced objects:
# oc get --raw /api/v1/ |  python -c 'import json,sys ; resources = "\n".join([o["name"] for o in json.load(sys.stdin)["resources"] if o["namespaced"] and "create" in o["verbs"] and "delete" in o["verbs"] ]) ; print(resources)'

set -eo pipefail

warnuser(){
    cat << EOF
###########
# WARNING #
###########
This script is distributed WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND
Beware ImageStreams objects are not importables due to the way they work
See https://github.com/openshift/openshift-ansible-contrib/issues/967
for more information
EOF
}

die(){
    echo "$1"
    exit "$2"
}

usage(){
    echo "$0 <projectname>"
    echo "  projectname  The name of the OCP project to be exported."
    echo "Examples:"
    echo "  $0 myproject"
    echo "Env variables:"
    echo "  BACKUP_SECRETS (default true) if secrets should be backed up."
    warnuser
}

exportlist(){
    if [ "$#" -lt "3" ]; then
        echo "Invalid parameters"
        return
    fi

    KIND=$1
    BASENAME=$2
    DELETEPARAM=$3

    echo "Exporting '${KIND}' resources to ${PROJECT}/${BASENAME}.json"

    BUFFER=$(oc get "${KIND}" --export -o json -n "${PROJECT}" || true)

    # return if resource type unknown or access denied
    if [ -z "${BUFFER}" ]; then
        echo "Skipped: no data"
        return
    fi

    # return if list empty
    if [ "$(echo "${BUFFER}" | jq '.items | length > 0')" == "false" ]; then
        echo "Skipped: list empty"
        return
    fi

    echo "${BUFFER}" | jq "${DELETEPARAM}" > "${PROJECT}/${BASENAME}.json"
}

ns(){
    exportlist \
        ns \
        ns \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

rolebindings(){
    exportlist \
        rolebindings \
        rolebindings \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

serviceaccounts(){
    exportlist \
        serviceaccounts \
        serviceaccounts \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

secrets(){
    exportlist \
        secrets \
        secrets \
        'del('\
'.items[]|select(.type=='\
'"'\
'kubernetes.io/service-account-token'\
'"'\
'))|'\
'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.annotations.'\
'"'\
'kubernetes.io/service-account.uid'\
'"'\
')'
}

dcs(){
    exportlist \
        dc \
        dcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].spec.triggers[].imageChangeParams.lastTriggeredImage'\
')'
}

bcs(){
    exportlist \
        bc \
        bcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.generation,'\
'.items[].spec.triggers[].imageChangeParams.lastTriggeredImage)'
}

builds(){
    exportlist \
        builds \
        builds \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

is(){
    exportlist \
        is \
        iss \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].metadata.annotations."openshift.io/image.dockerRepositoryCheck")'
}

rcs(){
    exportlist \
        rc \
        rcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

svcs(){
    exportlist \
        svc \
        svcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].spec.clusterIP)'
}

endpoints(){
    exportlist \
        endpoints \
        endpoints \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

pods(){
    exportlist \
        po \
        pods \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

cms(){
    exportlist \
        cm \
        cms \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

pvcs(){
    exportlist \
        pvc \
        pvcs \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].metadata.annotations['\
'"'\
'pv.kubernetes.io/bind-completed'\
'"'\
'],'\
'.items[].metadata.annotations['\
'"'\
'pv.kubernetes.io/bound-by-controller'\
'"'\
'],'\
'.items[].metadata.annotations['\
'"'\
'volume.beta.kubernetes.io/storage-provisioner'\
'"'\
'],'\
'.items[].spec.volumeName)'
}

pvcs_attachment(){
    exportlist \
        pvc \
        pvcs_attachment \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

routes(){
    exportlist \
        routes \
        routes \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

templates(){
    exportlist \
        templates \
        templates \
        'del('\
'.items[].status,'\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation)'
}

egressnetworkpolicies(){
    exportlist \
        egressnetworkpolicies \
        egressnetworkpolicies \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

imagestreamtags(){
    exportlist \
        imagestreamtags \
        imagestreamtags \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].tag.generation)'
}

rolebindingrestrictions(){
    exportlist \
        rolebindingrestrictions \
        rolebindingrestrictions \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

limitranges(){
    exportlist \
        limitranges \
        limitranges \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

resourcequotas(){
    exportlist \
        resourcequotas \
        resourcequotas \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

podpreset(){
    exportlist \
        podpreset \
        podpreset \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp)'
}

cronjobs(){
    exportlist \
        cronjobs \
        cronjobs \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

statefulsets(){
    exportlist \
        statefulsets \
        statefulsets \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

hpas(){
    exportlist \
        hpa \
        hpas \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].status)'
}

deployments(){
    exportlist \
        deploy \
        deployments \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

replicasets(){
    exportlist \
        replicasets \
        replicasets \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status,'\
'.items[].ownerReferences.uid)'
}

poddisruptionbudget(){
    exportlist \
        poddisruptionbudget \
        poddisruptionbudget \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

daemonset(){
    exportlist \
        daemonset \
        daemonset \
        'del('\
'.items[].metadata.uid,'\
'.items[].metadata.selfLink,'\
'.items[].metadata.resourceVersion,'\
'.items[].metadata.creationTimestamp,'\
'.items[].metadata.generation,'\
'.items[].status)'
}

BACKUP_SECRETS="${BACKUP_SECRETS:-true}"

if [[ ( $* == "--help") ||  $* == "-h" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 ]]; then
    usage
    die "projectname not provided" 2
fi

for i in jq oc; do
    command -v $i >/dev/null 2>&1 || die "$i required but not found" 3
done

warnuser

PROJECT="${1}"

mkdir -p "${PROJECT}"

ns
rolebindings
serviceaccounts
if [ ${BACKUP_SECRETS} ]; then
    secrets
fi
dcs
bcs
builds
is
imagestreamtags
rcs
svcs
endpoints
pods
podpreset
cms
egressnetworkpolicies
rolebindingrestrictions
limitranges
resourcequotas
pvcs
pvcs_attachment
routes
templates
cronjobs
statefulsets
hpas
deployments
replicasets
poddisruptionbudget
daemonset

exit 0

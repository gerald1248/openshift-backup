create:
	./create.sh

test:
	cd bin; ./openshift-backup_test

clean:
	./clean.sh

backupnow:
	oc rsh $(oc get po | grep 'openshift-backup.*Running' | head -n1 | awk '{ print $1 }') openshift-backup

default: create

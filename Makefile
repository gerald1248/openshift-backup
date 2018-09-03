create:
	./create.sh

test:
	cd bin; ./openshift-backup_test 

clean:
	./clean.sh

default: create

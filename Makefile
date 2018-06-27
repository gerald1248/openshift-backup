create:
	./create.sh

test:
	cd bin; ./openshift-backup_test 

clean:
	./clean.sh

build-docker-image:
	./build-docker-image.sh

default: create

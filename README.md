# OpenShift cluster backup

![Overview of openshift-backup](ditaa/backup-restore.png)

This project sets up a CronJob running the basic project backup script [project_export.sh on GitHub](https://raw.githubusercontent.com/openshift/openshift-ansible-contrib/master/reference-architecture/day2ops/scripts/project_export.sh).

Please note that no attempt is made to back up the contents of databases or mounted persistent volumes. This backup focuses on the API objects stored in `etcd`.

Admin access is required at the start (to create project and the `cluster-reader` ClusterRoleBinding for the service account), but from then on access is strictly controlled.

![Permissions](ditaa/permissions.png)

## Set the timer 
```
$ make
```

## Change configuration
Update `config/openshift-backup-config.json` and run:
```
$ make update-configmap
```

## Build your own Docker image
```
$ make build-docker-image
```

## Cleanup
Call `make clean` to remove the project `cluster-backup` and the rolebinding that gives the serviceaccount `openshift-backup` read-only access to all projects.

## Run the tests
These are only present as a scaffold for now, run:
```
$ make test
```

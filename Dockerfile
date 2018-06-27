FROM frolvlad/alpine-glibc
LABEL maintainer="Gerald Schmidt <gerald1248@gmail.com>"
LABEL description="Project backup for OpenShift clusters"
RUN apk add --no-cache curl jq
RUN addgroup -S app && adduser -S -g app app && \
  mkdir /openshift-backup && \
  chown app:app /openshift-backup
ADD downloads/oc /usr/bin/
ADD downloads/project_export.sh /usr/bin/
ADD downloads/project_import.sh /usr/bin/
ADD bin/openshift-backup /usr/bin/
WORKDIR /app
USER app
CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]

FROM openshift/base-centos7
LABEL maintainer="Gerald Schmidt <gerald1248@gmail.com>"
LABEL description="Project backup for OpenShift clusters"
RUN yum install -y zip
RUN groupadd app && useradd -g app app && \
  mkdir /openshift-backup && \
  chown app:app /openshift-backup
ADD downloads/oc /usr/bin/
ADD downloads/project_export.sh /usr/bin/
ADD downloads/project_import.sh /usr/bin/
ADD bin/openshift-backup /usr/bin/
RUN chmod +x /usr/bin/project_export.sh && chmod +x /usr/bin/project_import.sh
WORKDIR /app
USER app
CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]

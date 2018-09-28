FROM openshift/base-centos7:latest

LABEL maintainer="Gerald Schmidt <gerald1248@gmail.com>"
LABEL description="Project backup for OpenShift clusters"

RUN groupadd app && \
    useradd -g app app
RUN yum install -y epel-release
RUN yum install -y zip && \
    yum install -y jq centos-release-openshift-origin310 && \
    yum install -y origin-clients && \
    mkdir /openshift-backup && \
    mkdir /app && \
    chmod 777 /openshift-backup && \
    chmod 777 /app

ADD scripts/project_export.sh /usr/bin/
ADD bin/openshift-backup /usr/bin/

RUN chmod +x /usr/bin/project_export.sh

WORKDIR /app

USER app

CMD ["/bin/sh", "-c", "while true; do sleep 60; done"]

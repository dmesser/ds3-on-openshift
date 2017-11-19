FROM registry.access.redhat.com/rhel7:latest

RUN  yum repolist --disablerepo=* && \
     yum-config-manager --disable \* > /dev/null && \
     yum-config-manager --enable rhel-7-server-rpms > /dev/null && \
     yum -y update && \
     yum -y install mysql git

RUN mkdir /ds3

ENTRYPOINT ["mysql"]

CMD ["-u", "${MYSQL_USER}", "-p", "${MYSQL_PASSWORD}", "-h", "${MYSQL_HOST}", "<", "${SQL_FILE}"]

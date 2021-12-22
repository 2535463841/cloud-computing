FROM centos:7

RUN cd /etc/yum.repos.d && mkdir backup && mv *.repo backup
COPY *.repo /etc/yum.repos.d/
RUN yum clean all \
    && yum install -y mariadb mariadb-server \
    && yum clean all \
    && mysql_install_db

EXPOSE 3306
ENTRYPOINT [ "/usr/libexec/mysqld", "--user=root", "--datadir=/var/lib/mysql" ]

FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN yum -y install memcached \
    && systemctl enable memcached.service \
    && yum clean all

EXPOSE 11211
ENTRYPOINT [ "/usr/bin/memcached" ]
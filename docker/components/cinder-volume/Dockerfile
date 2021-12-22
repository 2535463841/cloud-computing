FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum -y install openstack-cinder python-pymemcache rbdclient \
    && yum clean all
RUN systemctl enable openstack-cinder-volume

ENTRYPOINT [ "cinder-volume" ]

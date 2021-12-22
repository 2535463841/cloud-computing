FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y openstack-nova-api python-novaclient openstack-nova-placement-api openstack-nova-center-compute-api \
    && yum clean all
RUN systemctl enable openstack-nova-api

EXPOSE 8774 8775
ENTRYPOINT [ "nova-api" ]

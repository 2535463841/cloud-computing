FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y openstack-nova-conductor python-cinderclient \
    && yum clean all
RUN systemctl enable openstack-nova-conductor

ENTRYPOINT [ "nova-conductor" ]

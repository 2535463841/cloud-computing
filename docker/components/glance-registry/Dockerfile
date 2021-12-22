FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum -y install openstack-glance python-glance python-glanceclient \
    && yum clean all
RUN systemctl enable openstack-glance-registry.service

ENTRYPOINT [ "/usr/bin/glance-registry" ]

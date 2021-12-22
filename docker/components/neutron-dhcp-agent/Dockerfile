FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y openstack-neutron-openvswitch net-tools \
    && yum clean all
RUN systemctl enable neutron-dhcp-agent

ENTRYPOINT [ "/usr/sbin/init" ]


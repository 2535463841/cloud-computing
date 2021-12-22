FROM centos:7

COPY *.repo /etc/yum.repos.d/
RUN rm -r /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum install -y openstack-neutron-ovn openvswitch-ovn-central python-networking-ovn openstack-neutron openstack-neutron-ml2 \
    && yum clean all
RUN systemctl enable neutron-server

EXPOSE 9696

ENTRYPOINT [ "/usr/sbin/init" ]

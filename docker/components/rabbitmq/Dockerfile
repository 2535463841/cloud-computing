FROM centos:7

COPY ./*.repo /etc/yum.repos.d/
COPY entrypoint.sh /
RUN rm -r /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum -y install rabbitmq-server \
    && systemctl enable rabbitmq-server.service \
    && yum clean all \
    && sed -i 's|^Wants=.*|Wants=network.target|g' /usr/lib/systemd/system/rabbitmq-server.service

EXPOSE 5672
ENTRYPOINT [ "/usr/sbin/init" ]

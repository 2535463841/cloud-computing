FROM centos:centos8

RUN yum install -y python38 \
    && pip3 install jupyter \
    && yum clean all

EXPOSE 8888
ENTRYPOINT [ "jupyter", "notebook", "--allow-root" ]

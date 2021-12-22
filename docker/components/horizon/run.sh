OPENSTACK_HOST=$1
IMAGE=openstack-dashboard:last

if [[ "${OPENSTACK_HOST}" == "" ]]; then
    echo "Usage: sh $0 <OPENSTACK_HOST> [HTTPD_OPTIONS]"
    echo "       OPENSTACK_HOST: The host of keystone server"
    echo "        HTTPD_OPTIONS: The options for httpd"
    exit 1
fi
docker run -itd --name openstack-dashboard \
	-p8080:80 \
	-v /etc/hosts:/etc/hosts \
	-P \
	"${IMAGE}" "${OPENSTACK_HOST}"

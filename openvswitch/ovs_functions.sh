
installOvs(){
    yum install -y openvswitch
    systemctl start openvswitch
    systemctl enable openvswitch
}


installOvnNorthd(){
    installOvs
    yum install -y openvswitch-ovn-central
    ovn-northd  openvswitch ovn-northd
    ovn-nbctl set-connection ptcp:6641:0.0.0.0 -- \
              set connection . inactivity_probe=60000
    ovn-sbctl set-connection ptcp:6642:0.0.0.0 -- \
              set connection . inactivity_probe=60000
    systemctl restart ovn-northd
}


installOvnController(){
    installOvs
    local ovnRemote=$1
    local ovnEncapIp=$2
    yum install -y openvswitch-ovn-host
    systemctl start openvswitch ovn-controller
    systemctl enable openvswitch ovn-controller
    ovs-vsctl set open . external-ids:ovn-remote=tcp:${ovnRemote}:6642
    ovs-vsctl set open . external-ids:ovn-encap-type=geneve
    ovs-vsctl set open . external-ids:ovn-encap-ip=${ovnEncapIp}
    systemctl restart openvswitch ovn-controller

    ovs-vsctl --may-exist add-br br-provider -- set bridge br-provider protocols=OpenFlow13
    # ovs-vsctl --may-exist add-port br-provider <ETH0>

}

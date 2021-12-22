INSTANCE_UUID=$1

DB_USER=root
DB_PASSWORD=root123
DB_HOST=127.0.0.1

logInfo(){
    echo -e "\033[1;34m $@ \033[0m"
}

logInfo "############################## PCI Request ###############################################"
mysql -u${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} nova --table << EOF
    select pci_requests, migration_context from instance_extra where instance_uuid='${INSTANCE_UUID}'\G
EOF

logInfo "############################ Block Device Mapping ########################################"
mysql -u${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} nova --table << EOF
  select id,volume_id,connection_info from block_device_mapping where instance_uuid='${INSTANCE_UUID}'\G
EOF

logInfo "################################# Pci Devices ###########################################"
mysql -u${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} nova --table << EOF
  select id, address, instance_uuid, request_id from pci_devices where instance_uuid='${INSTANCE_UUID}';
EOF

logInfo "################################ VM Interfaces ##########################################"
neutron port-list -c id -c name -c binding:host_id -c binding:profile --device-id ${INSTANCE_UUID}

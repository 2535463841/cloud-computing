
ROOT_PASSWORD=root123


started=false
for i in $(seq 60)
do
    echo "INFO: Try set root password ${i} times"
    mysql mysql -e "update user set authentication_string=password('${ROOT_PASSWORD}') where user='root';"
    if [[ $? -eq 0 ]]; then
        echo "INFO: set root password success"
        mysql -e "grant all privileges on *.* to 'root'@'localhost' identified by '${ROOT_PASSWORD}' with grant option;" || exit 1
        mysql -p${ROOT_PASSWORD} -e "grant all privileges on *.* to 'root'@'%' identified by '${ROOT_PASSWORD}' with grant option;" || exit 1
        mysql -p${ROOT_PASSWORD} -e "FLUSH privileges;"
        
        echo "INFO: set privileges success"
        exit 0
    fi
    sleep 1
done

echo "ERROR: init mariadb failed"


docker cp mariadb_init.sh mariadb:/
docker exec -it mariadb sh /mariadb_init.sh

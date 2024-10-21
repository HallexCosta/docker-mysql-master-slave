#!/bin/bash
MYSQL_HOST_MASTER=mysql_master
MYSQL_USER_MASTER=hallexcosta_master
MYSQL_PASSWORD_MASTER=hallexcosta_master_123
MYSQL_ROOT_PASSWORD=secret

MYSQL_USER_SLAVE=hallexcosta_slave_01
MYSQL_PASSWORD_SLAVE=hallexcosta_slave_01_123
# MYSQL_ROOT_PASSWORD_SLAVE=secret

docker compose down -v
rm -rf ./docker/mysql/master/data/*
rm -rf ./docker/mysql/slave-01/data/*
# rm -rf ./slave/data/*
docker compose build
docker compose up -d

until docker exec mysql_master sh -c 'export MYSQL_PWD=secret; mysql -u root -e ";"'
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done

priv_stmt='CREATE USER "hallexcosta_slave_01"@"%" IDENTIFIED BY "hallexcosta_slave_01_123"; GRANT REPLICATION SLAVE ON *.* TO "hallexcosta_slave_01"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e '$priv_stmt'"

until docker compose exec mysql_slave sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e ';'"
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done

MS_STATUS=`docker exec mysql_master sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e 'SHOW MASTER STATUS'"`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$MYSQL_HOST_MASTER',MASTER_USER='$MYSQL_USER_SLAVE',MASTER_PASSWORD='$MYSQL_PASSWORD_SLAVE',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd="export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e \""
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+="\""
echo $start_slave_cmd
docker exec mysql_slave sh -c "$start_slave_cmd"

docker exec mysql_slave sh -c "export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}; mysql -u root -e 'SHOW SLAVE STATUS \G'"

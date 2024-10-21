#!/bin/bash
CONTAINER_NAME=mysql_slave
MYSQL_HOST_MASTER=mysql_master
MYSQL_USER_SLAVE=hallexcosta_slave_01
MYSQL_PASSWORD_SLAVE=hallexcosta_slave_01_123
MYSQL_ROOT_PASSWORD=secret

createSlave $CONTAINER_NAME $MYSQL_HOST_MASTER $MYSQL_USER_SLAVE $MYSQL_PASSWORD_SLAVE $MYSQL_ROOT_PASSWORD

# until docker compose exec $DOCKER_CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e ';'"
# do
#     echo "Waiting for $DOCKER_CONTAINER_NAME database connection..."
#     sleep 4
# done

# start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$MYSQL_HOST_MASTER',MASTER_USER='$MYSQL_USER_SLAVE',MASTER_PASSWORD='$MYSQL_PASSWORD_SLAVE',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
# start_slave_cmd="export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e \""
# start_slave_cmd+="$start_slave_stmt"
# start_slave_cmd+="\""
# docker exec $DOCKER_CONTAINER_NAME sh -c "$start_slave_cmd"

# docker exec $DOCKER_CONTAINER_NAME sh -c "export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}; mysql -u root -e 'SHOW SLAVE STATUS \G'"
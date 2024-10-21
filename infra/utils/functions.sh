#!/bin/bash

function createMaster {
    CONTAINER_NAME=$1
    MYSQL_USER_SLAVE=$2
    MYSQL_PASSWORD_SLAVE=$3
    MYSQL_ROOT_PASSWORD=$4
    
    until docker exec $CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e ';'"
    do
        echo "Waiting for $CONTAINER_NAME database connection..."
        sleep 4
    done

    # users=(($CONTAINER_NAME, $MYSQL_USER_SLAVE, $MYSQL_PASSWORD_SLAVE, $MYSQL_ROOT_PASSWORD) ($CONTAINER_NAME, "hallexcosta_slave_02", "hallexcosta_slave_01_123", "secret"))
    
    # for user in ${users[@]}
    # do
    #     createUserMySQL $user[0] $user[1] $user[2] $user[3]
    #     sleep 6
    # done
    createUserMySQL $CONTAINER_NAME $MYSQL_USER_SLAVE $MYSQL_PASSWORD_SLAVE $MYSQL_ROOT_PASSWORD

    # priv_stmt="CREATE USER '$MYSQL_USER_SLAVE'@'%' IDENTIFIED BY '$MYSQL_PASSWORD_SLAVE'; GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_USER_SLAVE'@'%'; FLUSH PRIVILEGES;"
    # docker exec $CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e \"$priv_stmt\""

    MS_STATUS=`docker exec $CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e 'SHOW MASTER STATUS'"`
    CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
    CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`
}

function createUserMySQL {
    CONTAINER_NAME=$1
    MYSQL_USER_SLAVE=$2
    MYSQL_PASSWORD_SLAVE=$3
    MYSQL_ROOT_PASSWORD=$4
    priv_stmt="CREATE USER '$MYSQL_USER_SLAVE'@'%' IDENTIFIED BY '$MYSQL_PASSWORD_SLAVE'; GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_USER_SLAVE'@'%'; FLUSH PRIVILEGES;"
    docker exec $CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e \"$priv_stmt\""
}

function createSlave {
    if [ -z "$CURRENT_LOG" ]; then
        echo "Current LOG don't has value"
        return
    fi
    if [ -z "$CURRENT_POS" ]; then
        echo "Current POS don't has value"
        return
    fi

    CONTAINER_NAME=$1
    MYSQL_HOST_MASTER=$2
    MYSQL_USER_SLAVE=$3
    MYSQL_PASSWORD_SLAVE=$4
    MYSQL_ROOT_PASSWORD=$5

    until docker compose exec $CONTAINER_NAME sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e ';'"
    do
        echo "Waiting for $CONTAINER_NAME database connection..."
        sleep 4
    done

    start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$MYSQL_HOST_MASTER',MASTER_USER='$MYSQL_USER_SLAVE',MASTER_PASSWORD='$MYSQL_PASSWORD_SLAVE',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
    start_slave_cmd="export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -u root -e \""
    start_slave_cmd+="$start_slave_stmt"
    start_slave_cmd+="\""
    docker exec $CONTAINER_NAME sh -c "$start_slave_cmd"

    docker exec $CONTAINER_NAME sh -c "export MYSQL_PWD=${MYSQL_ROOT_PASSWORD}; mysql -u root -e 'SHOW SLAVE STATUS \G'"
}
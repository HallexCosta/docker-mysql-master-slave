#!/bin/bash
docker compose down -v
rm -rf ./docker/mysql/master/data/*
rm -rf ./docker/mysql/slave-01/data/*
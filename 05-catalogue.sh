#!/bin/bash

app_name=catalogue

source ./common.sh

check_root

app_setup
nodejs_setup
systemd_setup


cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo 
validate $? "Adding Mongodb repo"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "Install mongodb client"

# Load the data only once 
product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $logs_file)
validate $? "Connecting to MongoDB"

if [ "$product_count" -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $logs_file
    validate $? "Loading products"
else
    echo -e "$(timestamp) [INFO] Products are already loaded...${Y}SKIPPING${N}"
fi


restart
total_time
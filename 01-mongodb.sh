#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo 
validate $? "Adding the mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "Installing mongoDB"

systemctl enable mongod &>> $logs_file
systemctl start mongod &>> $logs_file
validate $? "Enable and start mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "Updating remote connections to mongoDB"

systemctl restart mongod &>> $logs_file
validate $? "Restart mongoDB"

total_time
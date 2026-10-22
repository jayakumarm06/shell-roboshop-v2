#!/bin/bash

source ./common.sh

check_root


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding Rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "enable and start Rabbitmq server"
###
##script idempotent, meaning you can run it multiple times without failing when the user already exists.
rabbitmqctl list_users | grep -w roboshop  &>/dev/null
if [ $? -ne 0 ]; then
   echo "$(timestamp) [INFO] Create a new User" | tee -a $logs_file
   rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
   rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
   validate $? "creating  user and set permissions for Rabbitmq  roboshop"
else  
   echo "$(timestamp) [INFO] Already User exists" | tee -a $logs_file
  
fi

total_time
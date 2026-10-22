#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"



if [ $user_id -ne 0 ]; then
    echo "Plse choose sudo access to.."
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

validate(){

    if  [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}...${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}...${G}SUCCESS${N}" | tee -a $logs_file
    fi

}

echo "$(timestamp) [INFO] ===== Script Started Execution =======" | tee -a $logs_file

# &>> $logs_file

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
# rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
# validate $? "creating  user and set permissions for Rabbitmq  roboshop"

#Here SECONDS is built in variables easy to use 
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file
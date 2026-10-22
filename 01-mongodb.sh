#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


# echo "++++++++++++++++++++++"
# # 01-mongodb.sh
# # mongodb_component=$(basename "$0" | cut -d'.' -f1 | cut -d'-' -f2)
# # echo "filename:$mongodb_component"
# mongo_component="mongodb"
# echo "filename:$mongo_component"

# echo "+++++++++++++++++++++++"

## Accessing the variables from roboshop-v1 to mongodb

source ./roboshop-v1.sh

echo "Hosted Zone Id:$hosted_zone_id" 
echo "Domain name:$domain_name"

## 

if [ $user_id -ne 0 ]; then
    echo "Plse choose sudo access to.."
    exit 1
fi

mkdir -p $logs_folder

validate(){
        if  [ $1 -ne 0 ]; then
            echo -e "${2}...${R}FAILED${N}" | tee -a $logs_file
            exit 1
        else
            echo -e "${2}...${G}SUCCESS${N}" | tee -a $logs_file
        fi

}

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
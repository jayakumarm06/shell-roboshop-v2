#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

source ./roboshop-v1.sh

# echo "++++++++++++++++++++++"
# # 06-user.sh
# # user_component=$(basename "$0" | cut -d'.' -f1 | cut -d'-' -f2)
# # echo "filename User:$user_component"
# # user_component="user"
# echo "+++++++++++++++++++++++"
## Accessing the variables from roboshop-v1 to mongodb

# source ./roboshop-v1.sh 

# echo "Hosted Zone Id:$hosted_zone_id" 
# echo "Domain name:$domain_name"


# for zone_id in $(aws route53 list-hosted-zones --output json | jq -r '.HostedZones[] | [.Id | sub("/hostedzone/"; ""), .Name] | @tsv' | while IFS=$'\t' read -r zone_id zone_name); do
#     echo "Checking Hosted Zone: $zone_name ($zone_id)"
    
#     # Add your condition and query here
#     if [[ "$zone_name" == *"mongodb"* ]] && [[ "$zone_name" == *"redis"* ]]; then
#         aws route53 list-resource-record-sets --hosted-zone-id "$zone_id" --output json \
#             | jq --arg query "mongodb" '.ResourceRecordSets[] | select(.Name | contains($query)) | {ZoneId: "'"$zone_id"'", Name: .Name, Type: .Type}'
#     fi
# done



## 



if [ $user_id -ne 0 ]; then
    echo "Plse choose sudo access to.."
    exit 1
fi

mkdir -p $logs_folder


#######################################################


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

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Installing nodesjs"

#Application User
id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Creating a system user"
else
    echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
fi

rm -rf /app
validate $? "Removing old Code"

mkdir -p /app 
validate $? "Creating app directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> $logs_file
validate $? "Download user"

cd /app 
unzip /tmp/user.zip &>> $logs_file
validate $? "unzip catalogue project file"

npm install &>> $logs_file
validate $? "Installing Dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/user.service"
cp "$scripts_dir/user.service" /etc/systemd/system/user.service

systemctl daemon-reload &>> $logs_file
systemctl enable user &>> $logs_file
systemctl start user &>> $logs_file
validate $? "Reload and enable,start the user service"

systemctl restart user &>> $logs_file
validate $? "Restart the user service"



#Here SECONDS is built in variables easy to use 
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file



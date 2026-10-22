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

dnf install golang -y &>> $logs_file
validate $? "Installing golang package"

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

curl -L -o /tmp/dispatch.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/dispatch-v4.zip &>> $logs_file
validate $? "Download dispatch"

cd /app 
unzip /tmp/dispatch.zip &>> $logs_file
validate $? "unzip dispatch project file"

cd /app 
go build -o dispatch  &>> $logs_file
validate $? "Installaling libraries"

# configure sytemd service and for particular user
sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/dispatch.service"
cp "$scripts_dir/dispatch.service" /etc/systemd/system/dispatch.service

# Load and start service
systemctl daemon-reload &>> $logs_file
systemctl enable dispatch &>> $logs_file
systemctl restart dispatch &>> $logs_file
validate $? "Restart the dispatch service"


#Here SECONDS is built in variables easy to use 
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file



#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
scripts_dir=$( dirname "$( realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

source ./roboshop-v2.sh

check_root(){

    if [ $user_id -ne 0 ]; then
        echo "Plse choose sudo access to.."
        exit 1
    fi

}
mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

echo "$(timestamp) [INFO] ===== Script Started Execution =======" | tee -a $logs_file

validate(){
        if  [ $1 -ne 0 ]; then
            echo -e "${2}...${R}FAILED${N}" | tee -a $logs_file
            exit 1
        else
            echo -e "${2}...${G}SUCCESS${N}" | tee -a $logs_file
        fi

}

nodejs_setup(){

    dnf module disable nodejs -y &>> $logs_file
    dnf module enable nodejs:24 -y &>> $logs_file
    dnf install nodejs -y &>> $logs_file
    validate $? "Installing nodesjs"

    npm install &>> $logs_file
    validate $? "Installing Dependencies"
}


app_setup(){

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

        curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $logs_file
        validate $? "Download $app_name"

        cd /app 
        unzip "/tmp/$app_name.zip" &>> $logs_file
        validate $? "unzip $app_name project file"

}

systemd_setup(){

        sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/$app_name.service"
        cp "$scripts_dir/$app_name.service" /etc/systemd/system/$app_name.service


        systemctl daemon-reload &>> $logs_file
        systemctl enable $app_name &>> $logs_file
        systemctl start $app_name &>> $logs_file
        validate $? "Reload and enable,start the $app_name service"


}

restart(){

    systemctl restart $app_name &>> $logs_file
    validate $? "Restart the $app_name service"

}


total_time(){
    
    #Here SECONDS is built in variables easy to use 
    echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
    echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file

}
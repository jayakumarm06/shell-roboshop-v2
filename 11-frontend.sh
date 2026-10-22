#!/bin/bash

source ./common.sh
check_root


dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y &>> $logs_file
validate $? "Installing nginx"

#Enable and start nginx
systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Reload and enable,start the nginx service"


rm -rf /usr/share/nginx/html/* &>> $logs_file
validate $? "Remove the default html page"

# Download aand extract frontend files
curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $logs_file
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $logs_file
validate $? "Create folder app and download the unzip project file"

# configure the reverse proxy
sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/roboshop.conf"
cp "$scripts_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf

# Check syntax and errors
nginx -t &>> $logs_file
validate $? "nginx configuration"

#restart nginx
systemctl restart nginx
validate $? "Restart nginx service"

total_time

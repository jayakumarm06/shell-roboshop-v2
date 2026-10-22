#!/bin/bash


app_name=shipping
source ./common.sh

check_root

app_setup
java_setup
systemd_setup


# Load master data
dnf install mysql -y &>> $logs_file
validate $? "Install mysql client"

# Load the cities data into the database
count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
    mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loading shipping data"
else
    echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi

# Load the app user data into the database
mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql 
validate $? "Load user data on mysql database"


restart
total_time

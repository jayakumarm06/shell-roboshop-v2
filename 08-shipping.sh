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

dnf module enable maven:3.9 -y &>> $logs_file
dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? "Installing maven and java"

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "Setting Java 25 as default Java version"


echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh 
echo $JAVA_HOME 
validate $? "Setting java path for maven"


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

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $logs_file
validate $? "Download shipping"

cd /app 
unzip /tmp/shipping.zip &>> $logs_file
validate $? "unzip shipping project file"

mvn clean package &>> $logs_file
validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar
validate $? "Moving shipping.jar file"

# create a system user and service
sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/shipping.service"
cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service


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


systemctl daemon-reload &>> $logs_file
systemctl enable shipping &>> $logs_file
systemctl restart shipping &>> $logs_file
validate $? "Restart the shipping service"




#Here SECONDS is built in variables easy to use 
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file



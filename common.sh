#!/bin/bash

user_id=$(id -u)

logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
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

total_time(){
    
    #Here SECONDS is built in variables easy to use 
    echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
    echo "$(timestamp) [INFO] ===== Script completed Execution =======" | tee -a $logs_file

}
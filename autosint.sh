#!/bin/bash

#usage: ./autosint $domain

domain=$1
RED="\033[1;31m"
RESET="\033[0m"


info_path=$domain/info
subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots

if [ ! -d "$domain" ];then
        mkdir $domain
fi

if [ ! -d "$info_path" ];then
        mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
        mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
        mkdir $screenshot_path
fi

echo -e "${RED} [+] Checking them out...${RESET}"
whois $1 > $info_path/whois.txt

echo -e "${RED} [+] Kicking Off subfinder...${RESET}"
subfinder -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Running assetfinder...${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

#echo -e "${RED} [+] Running amass. Gonna be a min... ${RESET}"
#amass enum -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Checking Heartbeat...${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a  $subdomain_path/alive.txt

echo -e "${RED} [+] Taking Screenshots ${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http

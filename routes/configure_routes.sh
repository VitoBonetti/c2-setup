# Shellscript to parse output from adidnsdump, extract all IP ranges with ipparser.py
# that can be used to add all possible routes to the ligolo interface.
# Author: andre marques

if [[ $1 == "" ]]; then
	echo "Usage: $0 records.csv";
	exit 0
fi

if [[ $(id -u) != "0" ]]; then
	echo "[!] You must be root in order to execute this script. Trust me bro."
	exit 0
fi


cat $1 |awk -F "," {'print $3'} | grep -P "\d+\.\d+\.\d+\.\d+" > iplist.txt
if [[ -f iplist.txt ]]; then
	python3 ipparser.py iplist.txt|bash
	exit 0
fi
echo "[!] If you see this, something went wrong :)"



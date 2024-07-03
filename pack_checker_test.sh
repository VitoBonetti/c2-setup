#!/bin/bash

packages_list_dpkg=("snapd" "python3-venv" "net-tools" "git" "plocate" "apache2" "hashcat" "gobuster" "dirb" "hping3" "john" "cewl" "smbmap" "socat" "screen" "whatweb" "sendemail" "unzip")
packages_list_snap=("go" "nmap" "rustscan" "sqlmap" "powershell" "enum4linux")

for package in "${packages_list_dpkg[@]}"; do
    if dpkg -s "$package" > /dev/null 2>&1; then
        echo "[+] $package correctly installed"
    else
        echo "[-] $package was not correctly installed"
    fi
done

for package in "${packages_list_snap[@]}"; do
    if snap list | grep "$package" > /dev/null 2>&1; then
        echo "[+] $package correctly installed"
    else
        echo "[-] $package was not correctly installed"
    fi
done

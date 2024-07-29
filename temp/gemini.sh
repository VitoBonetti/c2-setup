#!/bin/bash

start_time=$(date +%s)

# Define colors for console output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Print welcome banner
echo -e "${ORANGE}"
echo "   _____ ___              _____      _     _    _       "  
echo "  / ____|__ \            / ____|    | |   | |  | |      " 
echo " | |       ) |  ______  | (___   ___| |_  | |  | |_ __  "
echo " | |      / /  |______|  \___ \ / _ \ __| | |  | | '_ \ "
echo " | |____ / /_            ____) |  __/ |_  | |__| | |_) |"
echo "  \_____|____|          |_____/ \___|\__|  \____/| .__/ "
echo "                                                 | |    "
echo "                                                 |_|    "
echo -e "${NC}"

# Function to handle system updates
update_system() {
  echo -e "${BLUE}Updating the system...${NC}"
  if sudo apt update -y > /dev/null 2>&1; then
    echo -e "${GREEN}System update successfully!${NC}"
  else
    echo -e "${RED}Failed to update the system!${NC}"
  fi
}

# Function to handle system upgrades
upgrade_system() {
  echo -e "${BLUE}Upgrading the system...${NC}"
  if sudo apt upgrade -y > /dev/null 2>&1; then
    echo -e "${GREEN}System upgraded successfully!${NC}"
  else
    echo -e "${RED}Failed to upgrade the system!${NC}"
  fi
}

# Function to install packages
install_package() {
  local package_name="$1"
  echo -e "${BLUE}Installing $package_name...${NC}"
  if sudo apt install "$package_name" -y > /dev/null 2>&1; then
    echo -e "${GREEN}$package_name installed successfully!${NC}"
    echo "$package_name" >> /tmp/WHATisINSTALLED.txt
  else
    echo -e "${RED}Failed to install $package_name!${NC}"
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
  return $?
}

# Function to run a command and print the result
run_command() {
  local command="$1"
  echo -e "${BLUE}Running command: $command${NC}"
  if "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}Done!${NC}"
  else
    echo -e "${RED}Failed to run command: $command${NC}"
  fi
}

# Function to install and build tools from a git repository
install_from_git() {
  local repo_url="$1"
  local tool_name="$2"
  echo -e "${BLUE}Installing $tool_name...${NC}"
  run_command "git clone $repo_url"
  cd "$tool_name"
  if [ "$tool_name" == "ligolo-ng" ]; then
    run_command "go build -o proxy cmd/proxy/main.go"
    echo "$tool_name (go build)" >> /tmp/WHATisINSTALLED.txt
  elif [ "$tool_name" == "EnumShare" ]; then
    run_command "pip install -r requirements.txt"
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
  elif [ "$tool_name" == "kerbrute" ]; then
    run_command "pip install -r requirements.txt"
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
  elif [ "$tool_name" == "dnschef" ]; then
    run_command "pip install -r requirements.txt"
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
  elif [ "$tool_name" == "ldap-scanner" ]; then
    run_command "pip install impacket"
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
  elif [ "$tool_name" == "BloodHound.py" ]; then
    run_command "pip install ."
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
    touch BLOODHOUND.TXT
    echo "source /home/$current_user/env/bin/activate" > BLOODHOUND.TXT
    echo "cd /tmp/tools/BloodHound.py" >> BLOODHOUND.TXT
    echo "python3 bloodhound.py --help" >> BLOODHOUND.TXT
  elif [ "$tool_name" == "adidnsdump" ]; then
    run_command "pip install ."
    echo "$tool_name (pip install)" >> /tmp/WHATisINSTALLED.txt
  fi
  cd ..
  echo -e "${GREEN}Done!${NC}"
}

# Perform system updates and upgrades
update_system
upgrade_system

# Make /tmp folder persistent
echo -e "${BLUE}Make the /tmp folder persistance...${NC}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo "systemd-tmpfiles --cat-config tmp.conf" > CHECKTMPPERSISTANCE.TXT
echo -e "${GREEN}Done!${NC}"

# Clean up /tmp folder
echo -e "${BLUE}Moving into the /tmp folder and clean it up...${NC}"
cd /tmp
sudo rm -rf *
echo -e "${GREEN}Done!${NC}"
touch /tmp/WHATisINSTALLED.txt

# Install python3-venv and create virtual environment
install_package python3-venv
if command_exists python3; then
  echo -e "${BLUE}Creating python virtual environment env...${NC}"
  if python3 -m venv env; then
    echo -e "${GREEN}Python virtual environment created successfully!${NC}"
    sleep 5
  else
    echo -e "${RED}Failed to create python virtual environment!${NC}"
  fi
fi

# Activate virtual environment
echo -e "${BLUE}Activate environment...${NC}"
if source env/bin/activate; then
  echo -e "${GREEN}Done!${NC}"
  if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}No virtual environment is active.${NC}"
  else
    echo -e "${GREEN}Virtual environment is active: $VIRTUAL_ENV${NC}"
  fi
else
  echo -e "${RED}Failed to activate python virtual environment!Exiting...${NC}"
  exit 1
fi

# Install required packages
install_package net-tools
install_package mlocate
install_package apache2
install_package snapd
run_command "sudo snap install go --classic"
if command_exists go; then
  echo -e "${GREEN}go installed successfully!${NC}"
  echo "go" >> /tmp/WHATisINSTALLED.txt
else
  echo -e "${RED}Failed to install go!${NC}"
fi

# Install garble
run_command "go install mvdan.cc/garble@master"
echo "mvdan.cc/garble@master" >> /tmp/WHATisINSTALLED.txt

# Install wordlists
install_package wamerican
install_package wbrazilian
install_package wportuguese

# Install nmap
install_package nmap

# Install and build tools from git repositories
install_from_git "https://github.com/0x00-0x00/ligolo-ng" "ligolo-ng"
install_from_git "https://github.com/Brukusec/EnumShare.git" "EnumShare"
install_from_git "https://github.com/TarlogicSecurity/kerbrute" "kerbrute"
install_from_git "https://github.com/iphelix/dnschef.git" "dnschef"
install_from_git "https://github.com/GoSecure/ldap-scanner.git" "ldap-scanner"
install_from_git "https://github.com/dirkjanm/BloodHound.py.git" "BloodHound.py"
install_from_git "https://github.com/dirkjanm/adidnsdump" "adidnsdump"
install_from_git "https://github.com/Flangvik/SharpCollection" "SharpCollection"

# Create ligolo TUN adapter
current_user=$USER
sudo ip tuntap add user "$current_user" mode tun ligolo
sudo ip link set ligolo up
if command_exists ifconfig; then
  run_command "ifconfig ligolo"
  echo -e "${YELLOW}"
  echo "REMEMBER: You still need to add a new route to the ligolo TUN adapter."
  echo "          You also need to bind the Domain controller IP address to the name in the /etc/hosts file."
  echo "          This it will change for every test."
  echo -e "${NC}"
else
  echo -e "${RED}Failed to create ligolo TUN adapter!${NC}"
fi

# Install docker
echo -e "${YELLOW}"
echo "Docker is needed for run tool such as ManSpider and NetExec!"
echo -e "${NC}"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove "$pkg" > /dev/null 2>&1; done
update_system
install_package ca-certificates
install_package curl
sudo install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc  > /dev/null 2>&1
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
update_system
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y > /dev/null 2>&1
if sudo docker run hello-world; then
  echo -e "${GREEN}Done!${NC}"
  echo "Docker" >> /tmp/WHATisINSTALLED.txt
else 
  echo -e "${RED}Something went wrong! Exiting...${NC}"
  exit 1
fi

# Install ManSpider
run_command "sudo docker pull blacklanternsecurity/manspider"
if sudo docker run blacklanternsecurity/manspider --help; then
  echo -e "${GREEN}Done!${NC}"
  echo "ManSpider" >> /tmp/WHATisINSTALLED.txt
  touch MANSPIDER.TXT
  echo "sudo docker run blacklanternsecurity/manspider --help" > MANSPIDER.TXT
else 
  echo -e "${RED}Something went wrong! Impossible to install ManSpider.${NC}"
fi

# Install certipy-ad
run_command "pip install wheel"
run_command "pip install lxml==4.9.3"
run_command "pip install certipy-ad"
echo "Certipy-Ad" >> /tmp/WHATisINSTALLED.txt

# Install NetExec
run_command "git clone https://github.com/Pennyw0rth/NetExec"
cd NetExec
run_command "sudo docker build -t netexec:latest ."
if sudo docker run netexec --help; then
  cd ..
  echo -e "${GREEN}Done!${NC}"
  echo "NetExec (sudo docker run netexec --help)" >> /tmp/WHATisINSTALLED.txt
else 
  cd ..
  echo -e "${RED}Something went wrong! Impossible to install NetExec.${NC}"
fi

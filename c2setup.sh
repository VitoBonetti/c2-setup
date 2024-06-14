#!/bin/bash

start_time=$(date +%s)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

echo -e "${BLUE}Updating the system...${NC}"

if sudo apt update -y > /dev/null 2>&1; then
	echo -e "${GREEN}System update successfully!${NC}"
else
	echo -e "${RED}Failed to update the system!${NC}"
fi

echo -e "${BLUE}Upgrading the system...${NC}"

if sudo apt upgrade -y > /dev/null 2>&1; then
	echo -e "${GREEN}System upgraded successfully!${NC}"
else
	echo -e "${RED}Failed to upgrade the system!${NC}"
fi

echo -e "${BLUE}Make the /tmp folder persistance...${NC}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
touch CHECKTMPPERSISTANCE.TXT
echo "systemd-tmpfiles --cat-config tmp.conf" > CHECKTMPPERSISTANCE.TXT
echo -e "${GREEN}Done!${NC}"

echo -e "${BLUE}Moving into the /tmp folder and clean it up...${NC}"
cd /tmp
sudo rm -rf *
echo -e "${GREEN}Done!${NC}"
touch /tmp/WHATisINSTALLED.txt

echo -e "${BLUE}Installing python3-venv...${NC}"

if sudo apt install python3-venv -y > /dev/null 2>&1; then
	echo -e "${GREEN}python3-venv installed successfully!${NC}"
	echo -e "${BLUE}Creating python virtual environment env...${NC}"
	if python3 -m venv env; then
		echo -e "${GREEN}Python virtual environment created successfully!${NC}"
		sleep 5
	else
		echo -e "${RED}Failed to create python virtual environment!${NC}"
	fi
else
	 echo -e "${RED}Failed to install python3-venv!${NC}"
fi

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

echo -e "${BLUE}Installing net-tools...${NC}"

if sudo apt install net-tools -y > /dev/null 2>&1; then
	echo -e "${GREEN}net-tools installed successfully!${NC}"
	echo "net-tools" > /tmp/WHATisINSTALLED.txt
else
	echo -e "${RED}Failed to install net-tools!${NC}"
fi


echo -e "${BLUE}Installing mlocate...${NC}"

if sudo apt install mlocate -y > /dev/null 2>&1; then
	echo -e "${GREEN}mlocate installed successfully!${NC}"
 	echo -e "${BLUE}Installing apache2...${NC}"
else
	echo -e "${RED}Failed to install mlocate!${NC}"
fi
echo "mlocate" >> /tmp/WHATisINSTALLED.txt

echo -e "${BLUE}Installing apache2...${NC}"

sudo apt install apache2 -y > /dev/null 2>&1
if sudo systemctl status apache2; then
	echo -e "${GREEN}apache2 installed successfully!${NC}"
	echo "apache2" >> /tmp/WHATisINSTALLED.txt
else
	echo -e "${RED}Failed to install apache2!${NC}"
fi


echo -e "${BLUE}Installing go...${NC}"

sudo apt install snapd -y > /dev/null 2>&1
sudo snap install go --classic > /dev/null 2>&1
if go version; then
	echo -e "${GREEN}go installed successfully!${NC}"
 	echo "go" >> /tmp/WHATisINSTALLED.txt
else
	echo -e "${RED}Failed to install go!${NC}"
fi


echo -e "${BLUE}Installing garble...${NC}"
go install mvdan.cc/garble@master > /dev/null 2>&1
echo "mvdan.cc/garble@master" >> /tmp/WHATisINSTALLED.txt
echo -e "${GREEN}Done!${NC}"

echo -e "${BLUE}Installing wordlist to fattening the ligolo agent...${NC}"
sudo apt install wamerican wbrazilian wportuguese -y > /dev/null 2>&1
echo "wamerican wbrazilian wportuguese" >> /tmp/WHATisINSTALLED.txt
echo -e "${GREEN}Done!${NC}"

echo -e "${BLUE}Installing nmap...${NC}"

sudo apt install nmap -y > /dev/null 2>&1
if nmap --version; then
	echo -e "${GREEN}nmap installed successfully!${NC}"
 	echo "nmap" >> /tmp/WHATisINSTALLED.txt
else
	 echo -e "${RED}Failed to install nmap!${NC}"
fi


echo -e "${BLUE}Installing ligolo proxy...${NC}"
git clone https://github.com/0x00-0x00/ligolo-ng > /dev/null 2>&1
cd ligolo-ng
go build -o proxy cmd/proxy/main.go > /dev/null 2>&1
cd ..
echo -e "${GREEN}Done!${NC}"
echo "Ligolo Proxy " >> /tmp/WHATisINSTALLED.txt

echo -e "${BLUE}Create ligolo TUN adapter for the tunnel...${NC}"
current_user=$USER
sudo ip tuntap add user "$current_user" mode tun ligolo
sudo ip link set ligolo up
if ifconfig ligolo; then
	echo -e "${GREEN}Done!${NC}"
	echo -e "${YELLOW}"
	echo "REMEMBER: You still need to add a new route to the ligolo TUN adapter."
	echo "          You also need to bind the Domain controller IP address to the name in the /etc/hosts file."
	echo "          This it will change for every test."
	echo -e "${NC}"
	rm ligolo-ng_proxy_0.5.2_linux_amd64.tar
else
	echo -e "${RED}Failed to create ligolo TUN adapter!${NC}"
fi

echo -e "${BLUE}Cloning ligolo agent repository...${NC}"
git clone https://github.com/nicocha30/ligolo-ng  > /dev/null 2>&1
echo -e "${GREEN}Done!${NC}"


echo -e "${BLUE}Installing docker...${NC}"
echo -e "${YELLOW}"
echo "Docker is needed for run tool such as ManSpider and NetExec!"
echo -e "${NC}"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove $pkg > /dev/null 2>&1; done
sudo apt update -y > /dev/null 2>&1
sudo apt install ca-certificates curl -y > /dev/null 2>&1
sudo install -m 0755 -d /etc/apt/keyrings > /dev/null 2>&1
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc  > /dev/null 2>&1
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y > /dev/null 2>&1
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y > /dev/null 2>&1
if sudo docker run hello-world; then
	echo -e "${GREEN}Done!${NC}"
	echo "Docker" >> /tmp/WHATisINSTALLED.txt
else 
	echo -e "${RED}Something went wrong! Exiting...${NC}"
	exit 1
fi
echo -e "${BLUE}Installing ManSpider...${NC}"
sudo docker pull blacklanternsecurity/manspider > /dev/null 2>&1
if sudo docker run blacklanternsecurity/manspider --help; then
	echo -e "${GREEN}Done!${NC}"
	echo "ManSpider" >> /tmp/WHATisINSTALLED.txt
	touch MANSPIDER.TXT
	echo "sudo docker run blacklanternsecurity/manspider --help" > MANSPIDER.TXT
else 
	echo -e "${RED}Something went wrong! Impossible to install ManSpider.${NC}"
fi
echo -e "${BLUE}Installing certipy-ad...${NC}"
pip install wheel > /dev/null 2>&1
pip install lxml==4.9.3 > /dev/null 2>&1
pip install certipy-ad > /dev/null 2>&1
echo -e "${GREEN}Done!${NC}"
echo "Certipy-Ad" >> /tmp/WHATisINSTALLED.txt

echo -e "${BLUE}Installing EnumShare @Bruno...${NC}"

git clone https://github.com/Brukusec/EnumShare.git > /dev/null 2>&1 
cd EnumShare
pip install -r requirements.txt > /dev/null 2>&1
touch ENUMSHARE.TXT
echo "https://github.com/Brukusec/EnumShare" > ENUMSHARE.TXT
cd ..
echo -e "${GREEN}Done!${NC}"
echo "EnumShare @Bruno" >> /tmp/WHATisINSTALLED.txt

echo -e "${BLUE}Installing NetExec...${NC}"
git clone https://github.com/Pennyw0rth/NetExec > /dev/null 2>&1
cd NetExec
sudo docker build -t netexec:latest . > /dev/null 2>&1
if sudo docker run netexec --version; then
	cd ..
	echo -e "${GREEN}Done!${NC}"
	echo "NetExec (sudo docker run netexec --version)" >> /tmp/WHATisINSTALLED.txt
else 
	cd ..
	echo -e "${RED}Something went wrong! Impossible to install NetExec.${NC}"
fi

echo -e "${BLUE}Installing Kerbrute...${NC}"
pip install kerbrute > /dev/null 2>&1
if kerbrute -h; then
	echo -e "${GREEN}Done!${NC}"
	echo "Kerbrute" >> /tmp/WHATisINSTALLED.txt
else 
	git clone https://github.com/TarlogicSecurity/kerbrute > /dev/null 2>&1
	cd kerbrute
	pip install -r requirements.txt > /dev/null 2>&1
	if kerbrute --version; then
		cd ..
		echo -e "${GREEN}Done!${NC}"
	else
		cd ..
		echo -e "${RED}Something went wrong! Impossible to install Kerbrute.${NC}"
	fi
fi

echo -e "${BLUE}Installing DnsChef...${NC}"
git clone https://github.com/iphelix/dnschef.git > /dev/null 2>&1
cd dnschef
pip install -r requirements.txt > /dev/null 2>&1
if python3 dnschef.py -h; then
	cd ..
	echo -e "${GREEN}Done!${NC}"
	echo "DnsChef" >> /tmp/WHATisINSTALLED.txt
else
	cd .. 
	echo -e "${RED}Something went wrong! Impossible to install DnsChef.${NC}"
fi

echo -e "${BLUE}Installing ldap-scanner...${NC}"
git clone https://github.com/GoSecure/ldap-scanner.git > /dev/null 2>&1
cd ldap-scanner
pip install impacket > /dev/null 2>&1
if python3 ldap-scanner.py -h; then
	cd ..
	echo -e "${GREEN}Done!${NC}"
	echo "ldap-scanner" >> /tmp/WHATisINSTALLED.txt
else
	cd .. 
	echo -e "${RED}Something went wrong! Impossible to install ldap-scanner.${NC}"
fi

echo -e "${BLUE}Installing bloodhound.py...${NC}"
pip install bloodhound > /dev/null 2>&1
if bloodhound-python --help; then
	echo -e "${GREEN}Done!${NC}"
	echo "bloodhound.py (bloodhound-python --help)" >> /tmp/WHATisINSTALLED.txt
	touch BLOODHOUND.TXT
	echo "bloodhound-python --help" > BLOODHOUND.TXT
else
	git clone https://github.com/dirkjanm/BloodHound.py.git > /dev/null 2>&1
	cd BloodHound.py
	pip install . > /dev/null 2>&1
	if python3 bloodhound --help; then
		cd ..
		echo -e "${GREEN}Done!${NC}"
		echo "bloodhound.py (python3 bloodhound.py --help)" >> /tmp/WHATisINSTALLED.txt
		touch BLOODHOUND.TXT
		echo "source /home/$current_user/env/bin/activate" > BLOODHOUND.TXT
		echo "cd /tmp/tools/BloodHound.py" >> BLOODHOUND.TXT
		echo "python3 bloodhound.py --help" >> BLOODHOUND.TXT
	else
		cd .. 
		echo -e "${RED}Something went wrong! Impossible to install bloodhound.py.${NC}"
	fi
fi

echo -e "${BLUE}Installing adidnsdump...${NC}"

git clone https://github.com/dirkjanm/adidnsdump > /dev/null 2>&1
cd adidnsdump
pip install . > /dev/null 2>&1
if adidnsdump -h; then
	echo -e "${GREEN}adidnsdump installed successfully!${NC}"
 	cd ..
  	echo "adidnsdump" >> /tmp/WHATisINSTALLED.txt
else
	 echo -e "${RED}Failed to install adidnsdump!${NC}"
fi

end_time=$(date +%s)
execution_time=$((end_time - start_time))

echo "Execution time: $execution_time seconds"
echo -e "${GREEN}All Done!${NC}"
echo -e "${ORANGE}"
echo "  ____               ____              "
echo " |  _ \             |  _ \             "
echo " | |_) |_   _  ___  | |_) |_   _  ___  "
echo " |  _ <| | | |/ _ \ |  _ <| | | |/ _ \ "
echo " | |_) | |_| |  __/ | |_) | |_| |  __/ "
echo " |____/ \__, |\___| |____/ \__, |\___| "
echo "         __/ |              __/ |      "
echo "        |___/              |___/       "
echo -e "${NC}"

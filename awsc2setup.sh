
##### Tested

```
#!/bin/bash

G='\033[0;32m'
B='\033[0;34m'
O='\033[0;33m'
Y='\033[1;33m'
R='\033[0;31m'
N='\033[0m'

start_time=$(date +%s)

echo -e "${O}"
echo "[+] AWS - C2 SETUP"
echo "[*] Starting the process..."
echo -e "${N}"

echo -e "${B}[*] Updating the system...${N}"
if sudo apt update -y > /dev/null 2>&1; then
	echo -e "${G}[+] System update successfully!${N}"
else
	echo -e "$[-] {R}Failed to update the system!${N}"
fi

echo -e "${B}[*] Upgrading the system...${N}"
if sudo apt upgrade -y > /dev/null 2>&1; then
	echo -e "${G}[+] System upgraded successfully!${N}"
else
	echo -e "$[-] {R}Failed to upgrade the system!${N}"
fi

echo -e "${B}[*] Make the /tmp folder persistance...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "$[+] {G}Done!${N}"

echo -e "${B}[*] Installing Python virtual environment...${N}"
if sudo apt install python3-venv -y > /dev/null 2>&1; then
	echo -e "${G}[+] python3-venv installed successfully!${N}"
else
	 echo -e "$[-] {R}Failed to install python3-venv!${N}"
fi

echo -e "${B}[*] Creating 2 Python virtual environments.${N}"
echo -e "${R}[@] /opt/python-venv  --> High Privilages${N}"
echo -e "${Y}[@] /tmp/python-venv  --> Low  Privilages${N}"
cd /tmp
if python3 -m venv python-venv; then
	sleep 5
	echo -e "${G}[+] Low Privilages Python virtual environment created successfully!${N}"
	if source python-venv/bin/activate; then
		if [ -z "$VIRTUAL_ENV" ]; then
    		echo -e "${R}[-] No virtual environment is active.${N}"
		else
			echo -e "${G}[+] Virtual environment is active: $VIRTUAL_ENV${N}"
		fi
	else
		echo -e "${R}"
		echo "[-] Failed to activate Low Privilages Python virtual environment!"
		echo "[-] The script can't continue."
		echo "[-] Terminating.."
		echo -e "${N}"
		exit 1
	fi	
else
	echo -e "${R}"
	echo "[-] Failed to activate Low Privilages Python virtual environment!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

cd /opt
if sudo python3 -m venv python-venv; then
	sleep 5
	echo -e "${G}[+] High Privilages Python virtual environment created successfully!${N}"
	if source python-venv/bin/activate; then
		if [ -z "$VIRTUAL_ENV" ]; then
    		echo -e "${R}[-] No virtual environment is active.${N}"
		else
			echo -e "${G}[+] Virtual environment is active: $VIRTUAL_ENV${N}"
		fi
	else
		echo -e "${R}"
		echo "[-] Failed to activate High Privilages Python virtual environment!"
		echo "[-] The script can't continue."
		echo "[-] Terminating.."
		echo -e "${N}"
		exit 1
	fi	
else
	echo -e "${R}"
	echo "[-] Failed to activate High Privilages Python virtual environment!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

cd

echo -e "${B}[*] Installing net-tools...${N}"
if sudo apt install net-tools -y > /dev/null 2>&1; then
	if ifconfig > /dev/null 2>&1; then
		echo -e "${G}[+] net-tools installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install net-tools!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install net-tools!${N}"
	echo "[>] Continuing..."
fi


echo -e "${B}[*] Installing git...${N}"
if sudo apt install git -y > /dev/null 2>&1; then
	if git > /dev/null 2>&1; then
		echo -e "${G}[+] git installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install git!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install git!${N}"
	echo "[>] Continuing..."
fi


echo -e "${B}[*] Installing plocate...${N}"
if sudo apt install plocate -y > /dev/null 2>&1; then
	if locate -h > /dev/null 2>&1; then
		echo -e "${G}[+] plocate installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install plocate!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install plocate!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing apache2...${N}"
if sudo apt install apache2 -y > /dev/null 2>&1; then
	echo -e "${G}[+] apache2 installed successfully!${N}"
	sudo systemctl start apache2
	if sudo systemctl is-active --quiet apache2; then
		echo -e "${G}[+] apache2 web server is up and running!${N}"
	else
		echo -e "${R}[-] Failed to start apache2 web server!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install apache2 web server!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing golang...${N}"
sudo apt install snapd -y > /dev/null 2>&1
if sudo snap install go --classic > /dev/null 2>&1; then
	go version
	echo -e "${G}[+] golang installed successfully!${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install golang!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${B}[*] Installing garble...${N}"
if go install mvdan.cc/garble@master > /dev/null 2>&1; then
	echo -e "${G}[+] garble installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install garble!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing ligolo proxy...${N}"
cd /opt
sudo su
git clone https://github.com/0x00-0x00/ligolo-ng > /dev/null 2>&1
cd ligolo-ng
go build -o proxy cmd/proxy/main.go > /dev/null 2>&1
exit
cd
sudo ln -s /opt/ligolo-ng /usr/local/bin/lg-proxy
if lg-proxy -h > /dev/null 2>&1; then
	echo -e "${G}[+] ligolo proxy installed successfully!${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install ligolo proxy!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${B}[*] Create ligolo TUN adapter for the tunnel...${N}"
current_user=$USER
sudo ip tuntap add user "$current_user" mode tun ligolo
sudo ip link set ligolo upif ifconfig ligolo; then
	echo -e "${G}[+] ligolo TUN adapter created successfully!${N}"
	echo -e "${O}"
	echo "You need to add a new route to the ligolo TUN adapter."
	echo "You  need to bind the Domain controller IP address to the name in the /etc/hosts file."
	echo "This it will change depending from the target."
	echo -e "${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install ligolo TUN adapter!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${B}[*] Cloning ligolo agent...${N}"
cd /opt
sudo su
if git clone https://github.com/nicocha30/ligolo-ng ligolo-agent > /dev/null 2>&1; then
	echo -e "${G}[+] ligolo agent cloned successfully!${N}"
else
	echo -e "${R}[-] Failed to cloned ligolo agent!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing docker...${N}"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove $pkg; done;
sudo apt update -y 
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update -y 
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
if sudo docker run hello-world; then
	echo -e "${G}[+] docker installed successfully!${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install docker!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${B}[*] Installing manspider...${N}"
sudo docker pull blacklanternsecurity/manspider
if sudo docker run blacklanternsecurity/manspider --help; then
	echo -e "${G}[+] maspider installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install manspider!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing certipy-ad...${N}"
if [[ "$VIRTUAL_ENV" != "/tmp/python-ven" ]]; then
	source /tmp/python-ven/bin/activate
	pip install wheel
	pip install lxml==4.9.3
	pip install certipy-ad
else
	pip install wheel
	pip install lxml==4.9.3
	pip install certipy-ad
fi
echo -e "${G}[+] certipy-ad installed successfully!${N}"

echo -e "${B}[*] Installing NetExec...${N}"
cd /opt
sudo su
git clone https://github.com/Pennyw0rth/NetExec 
cd NetExec
sudo docker build -t netexec:latest . 
if sudo docker run netexec --help; then
	echo -e "${G}[+] netexec installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install netexec!${N}"
	echo "[>] Continuing..."
fi
exit
cd

echo -e "${B}[*] Installing kerbrute...${N}"
if [[ "$VIRTUAL_ENV" != "/tmp/python-ven" ]]; then
	source /tmp/python-ven/bin/activate
	pip install kerbrute
	pip install --upgrade setuptools
	if kerbrute; then
		echo -e "${G}[+] kerbrute installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install kerbrute!${N}"
		echo "[>] Continuing..."
	fi	
else
	pip install kerbrute
	pip install --upgrade setuptools
	if kerbrute; then
		echo -e "${G}[+] kerbrute installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install kerbrute!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing dnschef...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-ven" ]]; then
	sudo su
	source /opt/python-ven/bin/activate
	cd /opt
	git clone https://github.com/iphelix/dnschef.git
	cd dnschef
	pip install -r requirements.txt 
	if python3 dnschef.py -h; then
		echo -e "${G}[+] dnschef installed successfully!${N}"
		echo -e "$[*]{B}Creating dnschef wrapper...${N}"
		chmod +x dnschef.py
		exit
		cd
		sudo su
		touch /opt/dnschef/dnschef_wrapper.sh
		cat << 'EOF' > /opt/dnschef/dnschef_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec /opt/dnschef/dnschef.py "\$@" 
		EOF
		exit
		sudo chmod +x /opt/dnschef/dnschef_wrapper.sh
		sudo ln -s /opt/dnschef/dnschef_wrapper.sh /usr/local/bin/dnschef
		echo -e "${G}[+] dnschef wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install dnschef!${N}"
		echo "[>] Continuing..."
	fi	
else
	sudo su
	cd /opt
	git clone https://github.com/iphelix/dnschef.git
	cd dnschef
	pip install -r requirements.txt 
	if python3 dnschef.py -h; then
		echo -e "${G}[+] dnschef installed successfully!${N}"
		chmod +x dnschef.py
		exit
		cd
		sudo su
		touch /opt/dnschef/dnschef_wrapper.sh
		cat << 'EOF' > /opt/dnschef/dnschef_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec /opt/dnschef/dnschef.py "\$@" 
		EOF
		exit
		sudo chmod +x /opt/dnschef/dnschef_wrapper.sh
		sudo ln -s /opt/dnschef/dnschef_wrapper.sh /usr/local/bin/dnschef
		echo -e "${G}[+] dnschef wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install dnschef!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing ldap-scanner...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-ven" ]]; then
	sudo su
	source /opt/python-ven/bin/activate
	cd /opt
	git clone https://github.com/GoSecure/ldap-scanner.git 
	cd ldap-scanner
	pip install impacket 
	pip install --upgrade setuptools
	if python3 ldap-scanner.py -h; then
		echo -e "${G}[+] ldap-scanner installed successfully!${N}"
		echo -e "${B}[*] Creating ldap-scanner wrapper...${N}"
		chmod +x ldap-scanner.py
		exit
		cd
		sudo su
		touch /opt/ldap-scanner/ldap-scanner_wrapper.sh
		cat << 'EOF' > /opt/ldap-scanner/ldap-scanner_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec /opt/ldap-scanner/ldap-scanner.py "\$@" 
		EOF
		exit
		sudo chmod +x /opt/ldap-scanner/ldap-scanner_wrapper.sh
		sudo ln -s /opt/ldap-scanner/ldap-scanner_wrapper.sh /usr/local/bin/ldapscanner
		echo -e "${G}[+] ldap-scanner wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ldap-scanner!${N}"
		echo "[>] Continuing..."
	fi	
else
	sudo su
	cd /opt
	git clone https://github.com/GoSecure/ldap-scanner.git 
	cd ldap-scanner
	pip install impacket 
	pip install --upgrade setuptools
	if python3 ldap-scanner.py -h; then
		echo -e "${G}[+] ldap-scanner installed successfully!${N}"
		echo -e "${B}[*] Creating ldap-scanner wrapper...${N}"
		chmod +x ldap-scanner.py
		exit
		cd
		sudo su
		touch /opt/ldap-scanner/ldap-scanner_wrapper.sh
		cat << 'EOF' > /opt/ldap-scanner/ldap-scanner_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec /opt/ldap-scanner/ldap-scanner.py "\$@" 
		EOF
		exit
		sudo chmod +x /opt/ldap-scanner/ldap-scanner_wrapper.sh
		sudo ln -s /opt/ldap-scanner/ldap-scanner_wrapper.sh /usr/local/bin/ldapscanner
		echo -e "${G}[+] ldap-scanner wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ldap-scanner!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing bloodhound...${N}"
if [[ "$VIRTUAL_ENV" != "/tmp/python-ven" ]]; then
	source /tmp/python-ven/bin/activate
	pip install bloodhound 
	if bloodhound-python --help; then
		echo -e "${G}[+]bloodhound installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install bloodhound!${N}"
		echo "[>] Continuing..."
	fi	
else
	pip install bloodhound 
	if bloodhound-python --help; then
		echo -e "${G}[+]bloodhound installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install bloodhound!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing adidnsdump ...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-ven" ]]; then
	cd /opt
	sudo su
	source python-env/bin/activate
	git clone https://github.com/dirkjanm/adidnsdump 
	cd adidnsdump
	pip install . 
	if adidnsdump -h; then
		echo -e "${G}[+] adidnsdump installed successfully!${N}"
		echo -e "${B}[*] Creating adidnsdump wrapper...${N}"
		exit
		cd
		sudo su
		touch /opt/adidnsdump/adidnsdump_wrapper.sh
		cat << 'EOF' > /opt/adidnsdump/adidnsdump_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec adidnsdump "\$@" 
		EOF
		exit
		sudo chmod +x /opt/adidnsdump/adidnsdump_wrapper.sh
		sudo ln -s /opt/adidnsdump/adidnsdump_wrapper.sh /usr/local/bin/adidnsdump
		echo -e "${G}[+] adidnsdump wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install adidnsdump!${N}"
		echo "[>] Continuing..."
	fi	
else
	cd /opt
	sudo su
	git clone https://github.com/dirkjanm/adidnsdump 
	cd adidnsdump
	pip install . 
	if adidnsdump -h; then
		echo -e "${G}[+] adidnsdump installed successfully!${N}"
		echo -e "${B}[*] Creating adidnsdump wrapper...${N}"
		exit
		cd
		sudo su
		touch /opt/adidnsdump/adidnsdump_wrapper.sh
		cat << 'EOF' > /opt/adidnsdump/adidnsdump_wrapper.sh
		#!/bin/bash 
		
		source /opt/python-env/bin/activate 
		exec adidnsdump "\$@" 
		EOF
		exit
		sudo chmod +x /opt/adidnsdump/adidnsdump_wrapper.sh
		sudo ln -s /opt/adidnsdump/adidnsdump_wrapper.sh /usr/local/bin/adidnsdump
		echo -e "${G}[+] adidnsdump wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install adidnsdump!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing nmap ...${N}"
sudo snap install nmap
if nmap --version; then
	echo -e "${G}[+]nmap installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install nmap!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing ADenum ...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-ven" ]]; then
	sudo su
	cd /opt
	source python-env/bin/activate 
	git clone https://github.com/pelletierr/ADenum/
	cd ADenum
	sudo apt install build-essential -y
	sudo apt install libsasl2-dev python3-dev libldap2-dev libssl-dev -y
	systemctl daemon-reload
	pip install wheel
	pip install -r requirements.txt
	if python ADenum.py -h; then
			echo -e "${G}[+] ADenum installed successfully!${N}"
			echo -e "${B}[*] Creating ADenum wrapper...${N}"
			exit
			cd
			sudo su
			touch /opt/ADenum/adenum_wrapper.sh
			cat << 'EOF' > /opt/ADenum/adenum_wrapper.sh
			#!/bin/bash 
			
			source /opt/python-env/bin/activate 
			exec python3 /opt/ADenum/ADenum.py "\$@" 
			EOF
			exit
			sudo chmod +x /opt/ADenum/adenum_wrapper.sh
			sudo ln -s /opt/ADenum/adenum_wrapper.sh /usr/local/bin/adenum
			echo -e "${G}[+] ADenum wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ADenum!${N}"
		echo "[>] Continuing..."
	fi	
else
	sudo su
	cd /opt
	git clone https://github.com/pelletierr/ADenum/
	cd ADenum
	sudo apt install build-essential -y
	sudo apt install libsasl2-dev python3-dev libldap2-dev libssl-dev -y
	systemctl daemon-reload
	pip install wheel
	pip install -r requirements.txt
	if python ADenum.py -h; then
			echo -e "${G}[+] ADenum installed successfully!${N}"
			echo -e "${B}[*] Creating ADenum wrapper...${N}"
			exit
			cd
			sudo su
			touch /opt/ADenum/adenum_wrapper.sh
			cat << 'EOF' > /opt/ADenum/adenum_wrapper.sh
			#!/bin/bash 
			
			source /opt/python-env/bin/activate 
			exec python3 /opt/ADenum/ADenum.py "\$@" 
			EOF
			exit
			sudo chmod +x /opt/ADenum/adenum_wrapper.sh
			sudo ln -s /opt/ADenum/adenum_wrapper.sh /usr/local/bin/adenum
			echo -e "${G}[+] ADenum wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ADenum!${N}"
		echo "[>] Continuing..."
	fi	
fi

echo -e "${B}[*] Installing gmapsapiscanner ...${N}"
cd /opt
sudo su
git clone https://github.com/ozguralp/gmapsapiscanner.git
cd gmapsapiscanner
if python3 maps_api_scanner.py; then
	echo -e "${G}[+] gmapsapiscanner installed successfully!${N}"
	echo -e "${B}[*] Creating gmapsapiscanner wrapper...${N}"
	exit
	cd
	sudo su
	touch /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh
	cat << 'EOF' > /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh
	#!/bin/bash

	exec python3 /opt/gmapsapiscanner/maps_api_scanner.py "$@"
	EOF
	exit
	sudo chmod +x /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh
	sudo ln -s /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh /usr/local/bin/gmapsapiscanner
	echo -e "${G}[+] gmapsapiscanner wrapper created!${N}
else
	echo -e "${R}[-] Failed to install gmapsapiscanner!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing nikto...${N}"
cd /opt
sudo su
git clone https://github.com/sullo/nikto.git
cd nikto
docker build -t sullo/nikto .
if docker run --rm sullo/nikto; then
	echo -e "${G}[+] nikto installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install nikto!${N}"
	echo "[>] Continuing..."
fi	
exit
cd

echo -e "${B}[*] Installing SecLists...${N}"
sudo mkdir /usr/share/wordlists
cd /usr/share/wordlists
sudo su
git clone https://github.com/danielmiessler/SecLists.git
exit
cd
sudo chmod 755 /usr/share/wordlists
sudo chmod -R a+r /usr/share/wordlists
sudo find /usr/share/wordlists -type d -exec chmod 755 {} \;
echo -e "${G}[+] SecLists installed successfully!${N}"

echo -e "${B}[*] Installing hashcat...${N}"
sudo apt install hashcat -y
if hashcat -h; then
	echo -e "${G}[+] hashcat installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install hashcat!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing hydra...${N}"
sudo apt install hydra-gtk -y
if hydra -h; then
	echo -e "${G}[+] hydra installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install hydra!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing sqlmap...${N}"
sudo snap install sqlmap
if sqlmap -h; then
	echo -e "${G}[+] sqlmap installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install sqlmap!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing gobuster...${N}"
sudo apt install gobuster -y
if gobuster -h; then
	echo -e "${G}[+] gobuster installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install gobuster!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing dirb...${N}"
sudo apt install dirb -y
if dirb; then
	echo -e "${G}[+] dirb installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install dirb!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing hping3...${N}"
sudo apt install hping3 -y
if hping3 -h; then
	echo -e "${G}[+] hping3 installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install hping3!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing wpscan...${N}"
sudo apt  install ruby-rubygems -y
sudo apt install ruby-dev -y
sudo apt install build-essential -y
sudo gem install wpscan
if wpscan --version; then
	echo -e "${G}[+] wpscan installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install wpscan!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing powershell...${N}"
sudo snap install powershell --classic
if powershell --version; then
	echo -e "${G}[+] powershell installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install powershell!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing john...${N}"
sudo apt install john -y
if john; then
	echo -e "${G}[+] john installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install john!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing cewl...${N}"
sudo apt install cewl -y
if cewl -h; then
	echo -e "${G}[+] cewl installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install cewl!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing smbmap...${N}"
sudo apt install smbmap -y
if smbmap; then
	echo -e "${G}[+] smbmap installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install smbmap!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing socat...${N}"
sudo apt install socat -y
if socat -h; then
	echo -e "${G}[+] socat installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install socat!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing enum4linux...${N}"
sudo snap install enum4linux
if enum4linux -h; then
	echo -e "${G}[+] enum4linux installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install enum4linux!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing screen...${N}"
sudo apt install screen -y
if screen -h; then
	echo -e "${G}[+] screen installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install screen!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing whatweb...${N}"
sudo apt install whatweb -y
if whatweb -h; then
	echo -e "${G}[+] whatweb installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install whatweb!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing sendemail...${N}"
sudo apt install sendemail -y
if sendemail; then
	echo -e "${G}[+] sendemail installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install sendemail!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing gowitness...${N}"
sudo docker pull leonjza/gowitness
if sudo docker run --rm leonjza/gowitness gowitness; then
	echo -e "${G}[+] gowitness installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install gowitness!${N}"
	echo "[>] Continuing..."
fi

sudo su
mkdir /opt/whatihave
touch /opt/whatihave/whatihave.txt
cat << 'EOF' > /opt/whatihave/whatihave.txt

##########################################################################################
##                                USEFUL INFORMATION                                    ##
##########################################################################################

##########################################################################################
## Short cuts                                                                           ##
##########################################################################################
## Ligolo proxy             ## sudo lg-proxy                                            ##
## Dnschef                  ## sudo dnschef                                             ##
## ldap-scanner             ## sudo ldapscanner                                         ## 
## adidnsdump               ## sudo adidnsdump                                          ## 
## ADenum                   ## sudo adenum                                              ##
## Google Maps API Scanner  ## sudo gmapsapiscanner                                     ## 
##########################################################################################

##########################################################################################
## Locations                                                                            ##
##########################################################################################
## Ligolo agent             ## /opt/ligolo-agent                                        ##
## SecLists                 ## /usr/share/wordlist/SecLists                             ##
##########################################################################################

##########################################################################################
## Applications running in Docker                                                       ##
##########################################################################################
## ManSpider                ## sudo docker run blacklanternsecurity/manspider --help    ##
## NetExec                  ## sudo docker run netexec --help                           ##
## Nikto                    ## sudo docker run --rm sull/nikto                          ## 
## Gowitness                ## sudo docker run --rm leonjza/gowitness gowitness --help  ## 
##########################################################################################

## To see this message again run the command 'whatihave'...
## To see the complete list of tools run the command `inthebelly`...
EOF

chmod 644 /opt/whatihave/whatihave.txt
touch /opt/whatihave/whatihave_wrapper.sh
cat << 'EOF' > /opt/whatihave/whatihave_wrapper.sh
#!/bin/bash

exec cat /opt/whatihave/whatihave.txt
EOF
chmod +x /opt/whatihave/whatihave_wrapper.sh 
ln -s /opt/whatihave/whatihave_wrapper.sh /usr/local/bin/whatihave
echo "cat /opt/whatihave/whatihave.txt" >> /etc/bash.bashrc
source /etc/bash.bashrc

mkdir /opt/inthebelly
touch /opt/inthebelly/inthebelly.txt
cat << 'EOF' > /opt/inthebelly/inthebelly.txt

##########################################################
##              All installed packages                  ##
##########################################################
## - net-tools              ## - bloodhound-python      ##
## - git                    ## - adidnsdump **          ##
## - python3-venv           ## - nmap                   ##
## - plocate                ## - ADenum **              ##
## - apache2                ## - gmapsapiscanner **     ##
## - go                     ## - nikto *                ##
## - garble                 ## - SecLists ***           ##
## - ligolo-proxy **        ## - sendemail              ##
## - ligolo-agent ***       ## - socat                  ##
## - curl                   ## - hashcat                ##
## - ca-certificates        ## - hydra                  ##
## - docker                 ## - netcat                 ##
## - manspider *            ## - dnsdump                ##
## - certypy-ad             ## - sqlmap                 ##
## - netexec *              ## - gobuster               ##
## - kerbrute               ## - dirb                   ##
## - dnschef **             ## - hping3                 ##
## - ldap-scanner **        ## - ruby                   ##
## - wpscan                 ## - enum4linux             ##
## - powershell             ## - screen                 ##
## - john                   ## - whatweb                ##
## - cewl                   ## - gowitness *            ##
## - smbmap                 ##                          ##
########################################################## 
## *   Docker                                           ##
## **  Shortcut                                         ##
## *** Location                                         ##
##########################################################

## To see this message again run the command 'inthebelly'...
## To know more about docker apps, shortcut and locations run the command `whatihave`...
EOF
chmod 644 /opt/inthebelly/inthebelly.txt
touch /opt/inthebelly/inthebelly_wrapper.sh
cat << 'EOF' > /opt/inthebelly/inthebelly_wrapper.sh
#!/bin/bash

exec cat /opt/inthebelly/inthebelly.txt
EOF
chmod +x /opt/inthebelly/inthebelly_wrapper.sh 
ln -s /opt/inthebelly/inthebelly_wrapper.sh /usr/local/bin/inthebelly
exit
cd
inthebelly

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${0}"
echo "[+] Done"
echo "[+] Execution time: $execution_time seconds"
echo -e "${N}"
```

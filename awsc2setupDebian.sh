#!/bin/bash

# Declaring the colors
G='\033[0;32m'
B='\033[0;34m'
O='\033[0;33m'
Y='\033[1;33m'
R='\033[0;31m'
N='\033[0m'

# Troubleshoot color
P="\e[35m"

# Function to check if a package is installed 
is_installed() {
	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed" 
}

# Function to install a package if not already installed - APT
install_package() {
    local package=$1
    echo -e "${B}[*] Installing ${package}...${N}"
    if dpkg -s "${package}" > /dev/null 2>&1; then
        echo -e "${G}[+] ${package} is already installed!${N}"
    else
        if sudo apt install -y "${package}"; then
            if dpkg -s "${package}" > /dev/null 2>&1; then
                echo -e "${G}[+] ${package} installed successfully!${N}"
            else
                echo -e "${R}[-] Failed to verify ${package} installation!${N}"
                echo "[>] Continuing..."
            fi
        else
            echo -e "${R}[-] Failed to install ${package}!${N}"
            echo "[>] Continuing..."
        fi
    fi
}

# Function to install a package if not already installed - SNAP
install_snap() {
    local package=$1
    echo -e "${B}[*] Installing ${package}...${N}"
    if snap list | grep "$package" > /dev/null 2>&1; then
        echo -e "${G}[+] ${package} is already installed!${N}"
    else
         if sudo snap install "${package}"; then
            if  snap list | grep "$package" > /dev/null 2>&1; then
                echo -e "${G}[+] ${package} installed successfully!${N}"
            else
                echo -e "${R}[-] Failed to verify ${package} installation!${N}"
                echo "[>] Continuing..."
            fi
        else
            echo -e "${R}[-] Failed to install ${package}!${N}"
            echo "[>] Continuing..."
        fi
    fi
    
}

# starting the script
start_time=$(date +%s)

echo -e "${O}"
echo "[+] AWS - C2 SETUP"
echo "[*] Starting the process..."
echo -e "${N}"
echo -e "${B}[*] Updating Package sources${N}"

# Update package source
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb
sudo dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
echo "deb https://www.deb-multimedia.org bookworm main non-free" | sudo tee /etc/apt/sources.list.d/deb-multimedia.list
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/backports.list
echo "deb http://deb.debian.org/debian unstable main contrib non-free" | sudo tee /etc/apt/sources.list.d/unstable.list
sudo tee /etc/apt/preferences.d/unstable > /dev/null << 'EOF'
Package: *
Pin: release a=unstable
Pin-Priority: 50
EOF
sudo tee /etc/apt/preferences.d/bookworm > /dev/null << 'EOF'
Package: *
Pin: release a=bookworm
Pin-Priority: 900
EOF

echo -e "${B}[*] Updating the system...${N}"
sudo apt update -y
echo -e "${B}[*] Upgrading the system...${N}"
sudo apt dist-upgrade -y
sudo apt upgrade -y
cat /etc/apt/sources.list.d/deb-multimedia.list
cat /etc/apt/sources.list.d/backports.list
cat /etc/apt/sources.list.d/unstable.list

cat /etc/apt/sources.list.d/*
apt list --upgradable
echo -e "${G}[+] Package sources update successfully!${N}"

# Create persistence on the /tmp folder

echo -e "${B}[*] Make the /tmp folder persistence...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "${G}[+] Done!${N}"

echo -e "${B}[*] Installing snap.${N}"
sudo apt install snapd -y
if snap version; then
	echo -e "${G}[+] snap  installed successfully!${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install snap!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo "export PATH=\$PATH:/usr/sbin:/snap/bin:/sbin:/usr/bin/snap" | sudo tee -a /etc/bash.bashrc

# Directly export the PATH in the script so the script can continue and complete
export PATH=$PATH:/usr/sbin:/snap/bin:/sbin:/usr/bin/snap
echo $PATH
cd

# Install Python virtual environment and create 2 enviroment, high and low privilage in the /opt and /tmp folder
install_package "python3-venv"

echo -e "${B}[*] Creating 2 Python virtual environments.${N}"
echo -e "${Y}[^] /opt/python-venv  --> High Privilages${N}"
echo -e "${Y}[=] /tmp/python-venv  --> Low  Privilages${N}"

# Create low privilege virtual environment
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

# Create high privilege virtual environment
cd /opt
if sudo python3 -m venv python-venv; then
	sleep 5
	echo -e "${G}[+] High Privilages Python virtual environment created successfully!${N}"
	sudo -i bash<< 'EOF'
	source /opt/python-venv/bin/activate
	if [ -z "$VIRTUAL_ENV" ]; then
		echo -e "${R}[-] No virtual environment is active.${N}"
	else
		echo -e "${G}[+] Virtual environment is active: $VIRTUAL_ENV${N}"
	fi
EOF
else
	echo -e "${R}"
	echo "[-] Failed to activate High Privilages Python virtual environment!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

cd

install_package "net-tools"
install_package "git"
install_package "plocate"
install_package "apache2"

sudo systemctl start apache2
if sudo systemctl is-active --quiet apache2; then
	echo -e "${G}[+] apache2 web server is up and running!${N}"
else
	echo -e "${R}[-] Failed to start apache2 web server!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing golang...${N}"
if sudo snap install go --classic; then
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
if go install mvdan.cc/garble@master; then
	echo -e "${G}[+] garble installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install garble!${N}"
	echo "[>] Continuing..."
fi

GO_PATH="/snap/bin/go"

echo -e "${B}[*] Installing ligolo proxy...${N}"
cd /opt
sudo git clone https://github.com/0x00-0x00/ligolo-ng
cd ligolo-ng
sudo -E ${GO_PATH} build -o proxy cmd/proxy/main.go
cd
sudo ln -s /opt/ligolo-ng/proxy /usr/local/bin/lg-proxy
if lg-proxy -h; then
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
sudo ip link set ligolo up
if ifconfig ligolo; then
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
if sudo git clone https://github.com/nicocha30/ligolo-ng ligolo-agent; then
	echo -e "${G}[+] ligolo agent cloned successfully!${N}"
else
	echo -e "${R}[-] Failed to cloned ligolo agent!${N}"
	echo "[>] Continuing..."
fi
cd
echo -e "${B}[*] Installing docker...${N}"
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl gnupg -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl is-active docker
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
sudo git clone https://github.com/Pennyw0rth/NetExec 
cd NetExec
sudo docker build -t netexec:latest . 
if sudo docker run netexec --help; then
	echo -e "${G}[+] netexec installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install netexec!${N}"
	echo "[>] Continuing..."
fi

cd

echo -e "${B}[*] Installing kerbrute...${N}"
if [[ "$VIRTUAL_ENV" != "/tmp/python-ven" ]]; then
	source /tmp/python-ven/bin/activate
	pip install kerbrute
	pip install --upgrade setuptools
	if kerbrute --help; then
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
	sudo -i bash << 'EOF'
	source /opt/python-ven/bin/activate
	cd /opt
	git clone https://github.com/iphelix/dnschef.git
	cd dnschef
	pip install -r requirements.txt 
	if python3 dnschef.py -h; then
		echo -e "${G}[+] dnschef installed successfully!${N}"
		echo -e "$[*]{B}Creating dnschef wrapper...${N}"
		chmod +x dnschef.py
		cd
		tee /opt/dnschef/dnschef_wrapper.sh > /dev/null << 'EOFSCRIPT'
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec /opt/dnschef/dnschef.py "\$@" 
		EOFSCRIPT
		chmod +x /opt/dnschef/dnschef_wrapper.sh
		ln -s /opt/dnschef/dnschef_wrapper.sh /usr/local/bin/dnschef
		echo -e "${G}[+] dnschef wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install dnschef!${N}"
		echo "[>] Continuing..."
	fi
EOF

else
	sudo -i bash  << 'EOF'
	cd /opt
	git clone https://github.com/iphelix/dnschef.git
	cd dnschef
	pip install -r requirements.txt 
	if python3 dnschef.py -h; then
		echo -e "${G}[+] dnschef installed successfully!${N}"
		chmod +x dnschef.py
		cd
		tee /opt/dnschef/dnschef_wrapper.sh > /dev/nul  << 'EOFSCRIPT' 
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec /opt/dnschef/dnschef.py "\$@" 
		EOFSCRIPT
		
		chmod +x /opt/dnschef/dnschef_wrapper.sh
		ln -s /opt/dnschef/dnschef_wrapper.sh /usr/local/bin/dnschef
		echo -e "${G}[+] dnschef wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install dnschef!${N}"
		echo "[>] Continuing..."
	fi
EOF

fi

echo -e "${B}[*] Installing ldap-scanner...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-ven" ]]; then
	sudo -i bash<< 'EOF'
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
		cd
		tee /opt/ldap-scanner/ldap-scanner_wrapper.sh > /dev/null  << 'EOFSCRIPT' 
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec /opt/ldap-scanner/ldap-scanner.py "\$@" 
		EOFSCRIPT
		chmod +x /opt/ldap-scanner/ldap-scanner_wrapper.sh
		ln -s /opt/ldap-scanner/ldap-scanner_wrapper.sh /usr/local/bin/ldapscanner
		echo -e "${G}[+] ldap-scanner wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ldap-scanner!${N}"
		echo "[>] Continuing..."
	fi
EOF

else
	sudo -i bash << 'EOF'
	cd /opt
	git clone https://github.com/GoSecure/ldap-scanner.git 
	cd ldap-scanner
	pip install impacket 
	pip install --upgrade setuptools
	if python3 ldap-scanner.py -h; then
		echo -e "${G}[+] ldap-scanner installed successfully!${N}"
		echo -e "${B}[*] Creating ldap-scanner wrapper...${N}"
		chmod +x ldap-scanner.py
		cd
		tee /opt/ldap-scanner/ldap-scanner_wrapper.sh > /dev/null  << 'EOFSCRIPT' 
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec /opt/ldap-scanner/ldap-scanner.py "\$@" 
		EOFSCRIPT
		chmod +x /opt/ldap-scanner/ldap-scanner_wrapper.sh
		ln -s /opt/ldap-scanner/ldap-scanner_wrapper.sh /usr/local/bin/ldapscanner
		echo -e "${G}[+] ldap-scanner wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install ldap-scanner!${N}"
		echo "[>] Continuing..."
	fi	
EOF

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
	sudo -i bash << 'EOF'
	cd /opt
	source python-venv/bin/activate
	git clone https://github.com/dirkjanm/adidnsdump 
	cd adidnsdump
	pip install . 
	if adidnsdump -h; then
		echo -e "${G}[+] adidnsdump installed successfully!${N}"
		echo -e "${B}[*] Creating adidnsdump wrapper...${N}"
		cd
		tee /opt/adidnsdump/adidnsdump_wrapper.sh >/dev/null << 'EOFSCRIPT' 
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec adidnsdump "\$@" 
		EOFSCRIPT
		chmod +x /opt/adidnsdump/adidnsdump_wrapper.sh
		ln -s /opt/adidnsdump/adidnsdump_wrapper.sh /usr/local/bin/adidnsdump
		echo -e "${G}[+] adidnsdump wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install adidnsdump!${N}"
		echo "[>] Continuing..."
	fi
EOF

else
	sudo -i bash << 'EOF'
	cd /opt
	git clone https://github.com/dirkjanm/adidnsdump 
	cd adidnsdump
	pip install . 
	if adidnsdump -h; then
		echo -e "${G}[+] adidnsdump installed successfully!${N}"
		echo -e "${B}[*] Creating adidnsdump wrapper...${N}"
		cd
		tee /opt/adidnsdump/adidnsdump_wrapper.sh > /dev/null << 'EOFSCRIPT' 
		#!/bin/bash 
		
		source /opt/python-venv/bin/activate 
		exec adidnsdump "\$@" 
		EOFSCRIPT
		chmod +x /opt/adidnsdump/adidnsdump_wrapper.sh
		ln -s /opt/adidnsdump/adidnsdump_wrapper.sh /usr/local/bin/adidnsdump
		echo -e "${G}[+] adidnsdump wrapper created!${N}
	else
		echo -e "${R}[-] Failed to install adidnsdump!${N}"
		echo "[>] Continuing..."
	fi	
EOF

fi

install_snap "nmap"
install_snap "rustscan"	

echo -e "${B}[*] Installing ADenum ...${N}"
if [[ "$VIRTUAL_ENV" != "/opt/python-venv" ]]; then
	sudo -i bash << 'EOF'
	cd /opt
	source /opt/python-venv/bin/activate 
	git clone https://github.com/pelletierr/ADenum/
	cd ADenum
	apt install build-essential -y
	apt install libsasl2-dev python3-dev libldap2-dev libssl-dev -y
	systemctl daemon-reload
	pip install wheel
	pip install -r requirements.txt
	if python ADenum.py -h; then
 		echo -e "${G}[+] ADenum installed successfully!${N}"
		echo -e "${B}[*] Creating ADenum wrapper...${N}"
		cd
		tee /opt/ADenum/adenum_wrapper.sh > /dev/null << 'EOFSCRIPT' 
#!/bin/bash 

source /opt/python-venv/bin/activate 
exec python3 /opt/ADenum/ADenum.py "\$@" 
EOFSCRIPT
		chmod +x /opt/ADenum/adenum_wrapper.sh
		ln -s /opt/ADenum/adenum_wrapper.sh /usr/local/bin/adenum
		echo -e "${G}[+] ADenum wrapper created!${N}"
	else
		echo -e "${R}[-] Failed to install ADenum!${N}"
		echo "[>] Continuing..."
	fi
EOF

else
	sudo -i bash << 'EOF'
	cd /opt
	git clone https://github.com/pelletierr/ADenum/
	cd ADenum
	apt install build-essential -y
	apt install libsasl2-dev python3-dev libldap2-dev libssl-dev -y
	systemctl daemon-reload
	pip install wheel
	pip install -r requirements.txt
	if python ADenum.py -h; then
		echo -e "${G}[+] ADenum installed successfully!${N}"
		echo -e "${B}[*] Creating ADenum wrapper...${N}"
		cd
		tee /opt/ADenum/adenum_wrapper.sh > /dev/null << 'EOFSCRIPT'
#!/bin/bash 

source /opt/python-venv/bin/activate 
exec python3 /opt/ADenum/ADenum.py "\$@" 
EOFSCRIPT
		chmod +x /opt/ADenum/adenum_wrapper.sh
		ln -s /opt/ADenum/adenum_wrapper.sh /usr/local/bin/adenum
		echo -e "${G}[+] ADenum wrapper created!${N}"
	else
		echo -e "${R}[-] Failed to install ADenum!${N}"
		echo "[>] Continuing..."
	fi	
EOF

fi

echo -e "${B}[*] Installing gmapsapiscanner ...${N}"
cd /opt
sudo git clone https://github.com/ozguralp/gmapsapiscanner.git
cd gmapsapiscanner
if python3 maps_api_scanner.py -h; then
	echo -e "${G}[+] gmapsapiscanner installed successfully!${N}"
	echo -e "${B}[*] Creating gmapsapiscanner wrapper...${N}"
	cd
	sudo tee /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh > /dev/null << 'EOF' 
	#!/bin/bash

	exec python3 /opt/gmapsapiscanner/maps_api_scanner.py "$@"
EOF
	sudo chmod +x /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh
	sudo ln -s /opt/gmapsapiscanner/gmapsapiscanner_wrapper.sh /usr/local/bin/gmapsapiscanner
	echo -e "${G}[+] gmapsapiscanner wrapper created!${N}"
else
	echo -e "${R}[-] Failed to install gmapsapiscanner!${N}"
	echo "[>] Continuing..."
fi	

echo -e "${B}[*] Installing nikto...${N}"
cd /opt
sudo git clone https://github.com/sullo/nikto.git
cd nikto
sudo docker build -t sullo/nikto .
if sudo docker run --rm sullo/nikto -Version ; then
	echo -e "${G}[+] nikto installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install nikto!${N}"
	echo "[>] Continuing..."
fi

cd

echo -e "${B}[*] Installing SecLists...${N}"
sudo mkdir /usr/share/wordlists
cd /usr/share/wordlists
sudo git clone https://github.com/danielmiessler/SecLists.git
cd
sudo chmod 755 /usr/share/wordlists
sudo chmod -R a+r /usr/share/wordlists
sudo find /usr/share/wordlists -type d -exec chmod 755 {} \;
echo -e "${G}[+] SecLists installed successfully!${N}"

install_package "hashcat"
install_package "hydra-gtk"
install_snap "sqlmap"	
install_package "gobuster"
install_package "dirb"
install_package "hping3"
install_snap "powershell"	
install_snap "enum4linux"	

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

install_package "john"
install_package "cewl"
install_package "smbmap"
install_package "socat"
install_package "screen"
install_package "whatweb"
install_package "sendemail" 
install_package "unzip"

echo -e "${B}[*] Installing wine...${N}"
dpkg --print-architecture
sudo dpkg --add-architecture i386
dpkg --print-foreign-architectures
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
sudo apt update -y
sudo apt install --install-recommends winehq-stable -y
if wine --version; then
	echo -e "${G}[+] wine installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install wine!${N}"
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


sudo mkdir /opt/whatihave
sudo tee /opt/whatihave/whatihave.txt > /dev/null  << 'EOF' 

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

sudo chmod 644 /opt/whatihave/whatihave.txt
sudo tee /opt/whatihave/whatihave_wrapper.sh  > /dev/null  << 'EOF' 
#!/bin/bash

exec cat /opt/whatihave/whatihave.txt
EOF
sudo chmod +x /opt/whatihave/whatihave_wrapper.sh 
sudo ln -s /opt/whatihave/whatihave_wrapper.sh /usr/local/bin/whatihave
echo "cat /opt/whatihave/whatihave.txt" | sudo tee -a /etc/bash.bashrc
source /etc/bash.bashrc

sudo mkdir /opt/inthebelly
sudo tee /opt/inthebelly/inthebelly.txt  > /dev/null  << 'EOF' 

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
## - smbmap                 ## - rustscan               ##
## - unzip   		    ## - wine			##
########################################################## 
## *   Docker                                           ##
## **  Shortcut                                         ##
## *** Location                                         ##
##########################################################

## To see this message again run the command 'inthebelly'...
## To know more about docker apps, shortcut and locations run the command `whatihave`...
EOF
sudo chmod 644 /opt/inthebelly/inthebelly.txt
sudo tee /opt/inthebelly/inthebelly_wrapper.sh  > /dev/null  << 'EOF' 
#!/bin/bash

exec cat /opt/inthebelly/inthebelly.txt
EOF
sudo chmod +x /opt/inthebelly/inthebelly_wrapper.sh 
sudo ln -s /opt/inthebelly/inthebelly_wrapper.sh /usr/local/bin/inthebelly
cd
inthebelly

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${0}"
echo "[+] Done"
echo "[+] Execution time: $execution_time seconds"
echo -e "${N}"

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${0}"
echo "[+] Done"
echo "[+] Execution time: $execution_time seconds"
echo -e "${N}"

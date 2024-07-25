#!/bin/bash

# Declaring the colors
G="\033[0;32m"  # GREEN
B="\033[0;34m"  # BLUE
O="\033[0;33m"  # ORANGE
Y="\033[1;33m"  # YELLOW
R="\033[0;31m"  # RED
N="\033[0m"     # BLACK
P="\e[35m"      # PURPLE Troubleshoot color

install_package() {
    local package=$1
    echo -e "${O}[*] Installing ${package}...${N}"
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

install_snap() {
    local package=$1
    echo -e "${O}[*] Installing ${package}...${N}"
    if snap list | grep "$package" > /dev/null 2>&1; then
        echo -e "${G}[+] ${package} is already installed!${N}"
    else
        if sudo snap install "${package}"; then
            if snap list | grep "$package" > /dev/null 2>&1; then
                echo -e "${G}[+] ${package} installed successfully!${N}"
            else
                echo -e "${R}[-] Failed to verify ${package} installation!${N}"
                echo "[>] Continuing..."
            fi
        else
            if sudo snap install "${package}" --classic; then
                if snap list | grep "$package" > /dev/null 2>&1; then
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
    fi
}

# assign current user
current_user=$USER

# starting the script
start_time=$(date +%s)

echo -e "${B}"
echo "[+] C2 Setup"
echo "[*] Starting the process..."
echo -e "${N}"

echo -e "${O}[*] Determining linux distribution...${N}"

DESCRIPTION=$(lsb_release -d | awk -F'\t' '{print $2}')
if [[ "$DESCRIPTION" == *"Mint"* ]]; then
    OS="Mint"
elif [[ "$DESCRIPTION" == *"Debian"* ]]; then
    OS="Debian"
elif [[ "$DESCRIPTION" == *"Ubuntu"* ]]; then
    OS="Ubuntu"
else
    OS="Other"
fi

echo -e "${G}[+] ${DESCRIPTION} ${N}"
echo -e "${O}[*] Updating the system...${N}"
sudo apt update -y
echo -e "${O}[*] Upgrading the system...${N}"
sudo apt upgrade -y

if [[ $OS == "Mint" ]]; then
    sudo add-apt-repository universe
    sudo apt update -y
fi

echo -e "${O}[*] Installing development tools...${N}"

install_package "build-essential"
install_package "libc6-dev"
install_package "apt-utils"
install_package "libsasl2-dev" 
install_package "python3-dev" 
install_package "libldap2-dev" 
install_package "libssl-dev"
sudo systemctl daemon-reload

echo -e "${O}[*] Make the /tmp folder persistence...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Creating Git folder in '/home/${currenr_user}'... ${N}"
mkdir Git
echo -e "${G}[+] Done!${N}"

if [[ $OS == "Mint" ]]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python 
fi

install_package "python3-venv"

echo -e "${O}[*] Creating Python virtual environment.${N}"
if python -m venv env; then
	sleep 5
	echo -e "${G}[+]Python virtual environment created successfully!${N}"
	if source env/bin/activate; then
		if [ -z "$VIRTUAL_ENV" ]; then
    		echo -e "${R}[-] No virtual environment is active.${N}"
		else
			echo -e "${G}[+] Virtual environment is active: $VIRTUAL_ENV${N}"
		fi
	else
		echo -e "${R}"
		echo "[-] Failed to activate Python virtual environment!"
		echo "[-] The script can't continue."
		echo "[-] Terminating.."
		echo -e "${N}"
		exit 1
	fi	
else
	echo -e "${R}"
	echo "[-] Failed to activate Python virtual environment!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${O}[*] Installing snap.${N}"
if [[ $OS == "Mint" ]]; then
    wget http://security.ubuntu.com/ubuntu/pool/main/s/snapd/snapd_2.58+22.04.1_amd64.deb  
    sudo dpkg -i snapd_2.58+22.04.1_amd64.deb 
    if snap version; then
	    echo -e "${G}[+] snap  installed successfully!${N}"
        rm -f snapd_2.58+22.04.1_amd64.deb 
    else
        echo -e "${R}"
        echo "[-] Failed to install snap!"
        echo "[-] The script can't continue."
        echo "[-] Terminating.."
        echo -e "${N}"
        exit 1
    fi
else
    sudo apt install snapd -y
    if snap version  > /dev/null 2>&1; then
        echo -e "${G}[+] snap  installed successfully!${N}"
    else
        echo -e "${R}"
        echo "[-] Failed to install snap!"
        echo "[-] The script can't continue."
        echo "[-] Terminating.."
        echo -e "${N}"
        exit 1
    fi
fi

install_package "git"
install_package "apache2"

if sudo systemctl is-active --quiet apache2; then
	echo -e "${G}[+] apache2 web server is up and running!${N}"
else
    sudo systemctl start apache2
    if sudo systemctl is-active --quiet apache2; then
        echo -e "${G}[+] apache2 web server is up and running!${N}"
    else
        echo -e "${R}[-] Failed to start apache2 web server!${N}"
	    echo "[>] Continuing..."
    fi
fi

install_package "docker.io"
sudo docker run hello-world

install_package "hashcat"
install_package "hydra-gtk"
install_package "gobuster"
install_package "dirb"
install_package "hping3"

install_package "john"
install_package "cewl"
install_package "smbmap"
install_package "socat"
install_package "screen"
install_package "whatweb"
install_package "sendemail"
install_package "unzip"

install_package "ruby-rubygems"
install_package "ruby-dev"


install_snap "go"
install_snap "nmap"
install_snap "rustscan"
install_snap "sqlmap"
install_snap "enum4linux"
install_snap "powershell"

echo -e "${O}[*] Installing wpscan...${N}"
sudo gem install wpscan
if wpscan --version; then
	echo -e "${G}[+] wpscan installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install wpscan!${N}"
	echo "[>] Continuing..."
fi

echo -e "${O}[*] Installing wine...${N}"
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

if [ -z "$VIRTUAL_ENV" ]; then
    cd
    source env/bin/activate
    echo -e "${O}[*] Installing certipy-ad...${N}"
    if pip install wheel lxml==4.9.3 certipy-ad; then
        echo -e "${G}[+] certipy-ad installed successfully!${N}"
    else
        echo -e "${R}[-] Failed to install certipy-ad!${N}"
        echo "[>] Continuing..."
    fi
    echo -e "${O}[*] Installing kerbrute...${N}"
    pip install kerbrute
    pip install --upgrade setuptools
    if kerbrute --help; then
        echo -e "${G}[+] kerbrute installed successfully!${N}"
    else
        echo -e "${R}[-] Failed to install kerbrute!${N}"
        echo "[>] Continuing..."
    fi	
    echo -e "${B}[*] Installing bloodhound...${N}"
    pip install bloodhound 
    if bloodhound-python --help; then
        echo -e "${G}[+]bloodhound installed successfully!${N}"   
	else
		echo -e "${R}[-] Failed to install bloodhound!${N}"
		echo "[>] Continuing..."
	fi
else
    echo -e "${O}[*] Installing certipy-ad...${N}"
    if pip install wheel lxml==4.9.3 certipy-ad; then
        echo -e "${G}[+] certipy-ad installed successfully!${N}"
    else
        echo -e "${R}[-] Failed to install certipy-ad!${N}"
        echo "[>] Continuing..."
    fi
    echo -e "${O}[*] Installing kerbrute...${N}"
    pip install kerbrute
    pip install --upgrade setuptools
    if kerbrute --help; then
        echo -e "${G}[+] kerbrute installed successfully!${N}"
    else
        echo -e "${R}[-] Failed to install kerbrute!${N}"
        echo "[>] Continuing..."
    fi	
fi

echo -e "${B}[*] Installing garble...${N}"
if go install mvdan.cc/garble@master; then
	echo -e "${G}[+] garble installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install garble!${N}"
	echo "[>] Continuing..."
fi

echo -e "${O}[*] Docker Container Apps ...${N}"


echo -e "${B}[*] Installing manspider...${N}"
sudo docker pull blacklanternsecurity/manspider
if sudo docker run blacklanternsecurity/manspider --help; then
	echo -e "${G}[+] maspider installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install manspider!${N}"
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

cd Git
echo -e "${O}[*] Cloning NetExec...${N}"
git clone https://github.com/Pennyw0rth/NetExec
cd NetExec
echo -e "${B}[*] Installing NetExec...${N}"
sudo docker build -t netexec:latest . 
if sudo docker run netexec --help; then
	echo -e "${G}[+] netexec installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install netexec!${N}"
	echo "[>] Continuing..."
fi
cd

cd Git
echo -e "${O}[*] Cloning nikto...${N}"
git clone https://github.com/sullo/nikto.git
cd nikto
echo -e "${B}[*] Installing nikto...${N}"
sudo docker build -t sullo/nikto .
if sudo docker run --rm sullo/nikto -Version ; then
	echo -e "${G}[+] nikto installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install nikto!${N}"
	echo "[>] Continuing..."
fi
cd


echo -e "${O}[*] Cloning repositories...${N}"
if [ -z "$VIRTUAL_ENV" ]; then
    source /home/${currenr_user}/env/bin/activate
fi
cd Git
echo -e "${O}[*] Cloning Ligolo proxy...${N}"
git clone https://github.com/0x00-0x00/ligolo-ng
cd ligolo-ng
go build -o lg-proxy cmd/proxy/main.go
if lg-proxy -h; then
    cd ..
	echo -e "${G}[+] ligolo proxy installed successfully!${N}"
else
	echo -e "${R}"
	echo "[-] Failed to install ligolo proxy!"
	echo "[-] The script can't continue."
	echo "[-] Terminating.."
	echo -e "${N}"
	exit 1
fi

echo -e "${O}[*] Create ligolo TUN adapter for the tunnel...${N}"
sudo ip tuntap add user "$current_user" mode tun ligolo
sudo ip link set ligolo up
if ifconfig ligolo; then
	echo -e "${G}[+] ligolo TUN adapter created successfully!${N}"
	echo -e "${B}"
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

echo -e "${O}[*] Cloning Ligolo agent...${N}"
if git clone https://github.com/nicocha30/ligolo-ng ligolo-agent; then
    echo -e "${G}[+] ligolo agent cloned successfully!${N}"
else
	echo -e "${R}[-] Failed to cloned ligolo agent!${N}"
	echo "[>] Continuing..."
fi

echo -e "${O}[*] Cloning dnschef...${N}"
git clone https://github.com/iphelix/dnschef.git
echo -e "${O}[*] Installing dnschef...${N}"
cd dnschef
pip install -r requirements.txt 
if python dnschef.py -h; then
    echo -e "${G}[+] dnschef installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install dnschef!${N}"
    echo "[>] Continuing..."
fi
cd..

echo -e "${O}[*] Cloning ldap-scanner...${N}"
git clone https://github.com/GoSecure/ldap-scanner.git 
echo -e "${O}[*] Installing ldap-scanner...${N}"
cd ldap-scanner
pip install impacket 
pip install --upgrade setuptools
if python ldap-scanner.py -h; then
    echo -e "${G}[+] ldap-scanner installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install ldap-scanner!${N}"
    echo "[>] Continuing..."
fi
cd..

echo -e "${O}[*] Cloning adidnsdump...${N}"
git clone https://github.com/dirkjanm/adidnsdump 
echo -e "${O}[*] Installing adidnsdump ...${N}"
cd adidnsdump
pip install . 
if adidnsdump -h; then
    echo -e "${G}[+] adidnsdump installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install adidnsdump!${N}"
    echo "[>] Continuing..."
fi
cd..


echo -e "${O}[*] Cloning ADenum...${N}"
git clone https://github.com/pelletierr/ADenum/
echo -e "${O}[*] Installing ADenum ...${N}"
cd ADenum
pip install wheel
pip install -r requirements.tx
if ADenum.py -h; then
    echo -e "${G}[+] ADenum installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install ADenum!${N}"
    echo "[>] Continuing..."
fi
cd..


echo -e "${O}[*] Cloning gmapsapiscanner...${N}"
git clone https://github.com/ozguralp/gmapsapiscanner.git
cd gmapsapiscanner
if python3 maps_api_scanner.py -h; then
	echo -e "${G}[+] gmapsapiscanner installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install gmapsapiscanner!${N}"
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


echo -e "${O}[*] Updating database...${N}"
sudo updatedb
echo -e "${G}[+] Database successfully updated...${N}"
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${G}[+] Done${N}"
echo -e "${0}[+] Execution time: $execution_time seconds${N}"

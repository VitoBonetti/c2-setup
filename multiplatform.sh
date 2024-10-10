#!/bin/bash

# Declaring the colors
G="\033[0;32m"  # GREEN
B="\033[0;34m"  # BLUE
O="\033[0;33m"  # ORANGE
Y="\033[1;33m"  # YELLOW
R="\033[0;31m"  # RED
N="\033[0m"     # BLACK
C="\033[0;36m"  # CYAN
P="\e[35m"      # PURPLE Troubleshoot color

install_apt() {
    local packages=("$@")
    for package in "${packages[@]}"; do
	    echo -e "${B}[*] Installing $package...${N}"
	    if dpkg -s "$package" > /dev/null 2>&1; then
	        echo -e "${C}[>] $package is already installed!${N}"
	        echo -e "${C}[>] Continuing...${N}"
	    else
	        if sudo apt install -y "$package" > /dev/null 2>&1; then
	            if dpkg -s "$package" > /dev/null 2>&1; then
	                echo -e "${G}[+] $package installed successfully!${N}"
	            else
	                echo -e "${R}[-] Failed to verify $package installation!${N}"
	                echo -e "${C}[>] Continuing...${N}"
	            fi
	        else
	            echo -e "${R}[-] Failed to install $package!${N}"
	            echo -e "${C}[>] Continuing...${N}"
	        fi
	    fi
	done
}

install_snap() {
    local packages=("$@")
    for package in "${packages[@]}"; do
	    echo -e "${B}[*] Installing $package...${N}"
	    if snap list | grep "$package" > /dev/null 2>&1; then
	        echo -e "${C}[>] $package is already installed!${N}"
	        echo -e "${C}[>] Continuing...${N}"
	    else
	        if sudo snap install "${package}" > /dev/null 2>&1; then
	            if snap list | grep "$package" > /dev/null 2>&1; then
	                echo -e "${G}[+] $package installed successfully!${N}"
	            else
	                echo -e "${R}[-] Failed to verify $package installation!${N}"
	                echo -e "${C}[>] Continuing...${N}"
	            fi
	        else
	            if sudo snap install "$package" --classic > /dev/null 2>&1; then
	                if snap list | grep "$package" > /dev/null 2>&1; then
	                    echo -e "${G}[+] $package installed successfully!${N}"
	                else    
	                    echo -e "${R}[-] Failed to verify $package installation!${N}"
	                    echo -e "${C}[>] Continuing...${N}"
	                fi
	            else
	                echo -e "${R}[-] Failed to install $package!${N}"
	                echo -e "${C}[>] Continuing...${N}"
	            fi
	        fi
	    fi
	done
}

install_pip() {
    local packages=("$@")
    for package in "${packages[@]}"; do
		echo -e "${B}[*] Installing python $package...${N}"
		if pip install "$package" > /dev/null 2>&1; then
		    echo -e "${G}[+] ${package} successfully installed!${N}"
		else
		    echo -e "${R}[-] Failed to install $package python package!${N}"
		    echo -e "${C}[>] Continuing...${N}"
		fi
	done
}

install_git () {
	local repositories=("$@")
	for repository in "${repositories[@]}"; do
		echo -e "${B}[*] Cloning $repository ...${N}"
		if git clone "$repository" > /dev/null 2>&1; then
			echo -e "${G}[+] $repository successfully cloned!${N}"
		else
			echo -e "${R}[-] Failed to clone $repository !${N}"
			echo -e "${C}[>] Continuing...${N}"
		fi
	done
	
}

update_system() {
  echo -e "${B}[*] Updating the system...${N}"
  if sudo apt update -y > /dev/null 2>&1; then
    echo -e "${G}[+] System update successfully!${N}"
  else
    echo -e "${R}[-] Failed to update the system!${N}"
  fi
}

upgrade_system() {
  echo -e "${B}[*] Upgrading the system...${N}"
  if sudo apt upgrade -y > /dev/null 2>&1; then
    echo -e "${G}[+] System upgraded successfully!${N}"
  else
    echo -e "${R}[-] Failed to upgrade the system!${N}"
  fi
}

declare -A ubuntu
declare -A debian

ubuntu["apt"]="build-essential libsasl2-dev python3-dev libldap2-dev libssl-dev net-tools libreadline-dev zlib1g-dev gnupg2 python3-venv nmap apache2 docker.io hashcat hydra-gtk gobuster dirb hping3 john cewl smbmap whatweb sendemail socat wine64"
ubuntu["snap"]="sqlmap enum4linux"
ubuntu["pip"]="wheel pyOpenSSL==24.0.0 lxml==4.9.3 setuptools certipy-ad kerbrute bloodhound impacket"
ubuntu["git"]="https://github.com/Pennyw0rth/NetExec https://github.com/sullo/nikto.git https://github.com/0x00-0x00/ligolo-ng https://github.com/iphelix/dnschef.git https://github.com/GoSecure/ldap-scanner.git https://github.com/dirkjanm/adidnsdump https://github.com/VitoBonetti/ADenum.git https://github.com/ozguralp/gmapsapiscanner.git https://github.com/njcve/inflate.py https://github.com/dirkjanm/ROADtools.git"

debian["apt"]="build-essential libsasl2-dev python3-dev libldap2-dev libssl-dev net-tools libreadline-dev zlib1g-dev gnupg2 python3-venv nmap apache2 docker.io hashcat hydra-gtk gobuster dirb hping3 john cewl smbmap whatweb sendemail socat wine64 git snapd plocate"
debian["snap"]="sqlmap enum4linux"
debian["pip"]="wheel pyOpenSSL==24.0.0 lxml==4.9.3 setuptools certipy-ad kerbrute bloodhound impacket"
debian["git"]="https://github.com/Pennyw0rth/NetExec https://github.com/sullo/nikto.git https://github.com/0x00-0x00/ligolo-ng https://github.com/iphelix/dnschef.git https://github.com/GoSecure/ldap-scanner.git https://github.com/dirkjanm/adidnsdump https://github.com/VitoBonetti/ADenum.git https://github.com/ozguralp/gmapsapiscanner.git https://github.com/njcve/inflate.py https://github.com/dirkjanm/ROADtools.git"

order=("apt" "pip" "snap" "git")

os_version=$(lsb_release -d | awk -F'\t' '{print $2}')

start_time=$(date +%s)
echo -e "${G}[+] C2 Setup${N}"
echo -e "${P}[#] Welcome $USER ${N}"
echo -e "${B}[*] Starting the process...${N}"
echo -e "${G}[+] Linux distribution${N} ${O}$os_version.${N}"

update_system
upgrade_system

echo -e "${B}[*] Making the /tmp folder persistent...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "${G}[+] Done!${N}"

echo -e "${B}[*] Creating Git folder in '/home/$USER'... ${N}"
mkdir ~/Git
echo -e "${G}[+] Done!${N}"

echo -e "${B}[*] Creating Tools folder in '/home/$USER'... ${N}"
mkdir ~/Tools
echo -e "${G}[+] Done!${N}"


if [[ $os_version == *"Ubuntu"* ]]; then
	for key in "${order[@]}"; do
        if [[ $key == "apt" ]]; then
            echo -e "${O}[*] Installing packages with APT${N}"
            install_apt ${ubuntu[$key]}

			if [[ $os_version == *"24.04"* ]]; then
				echo -e "${B}[*] Installing plocate... ${N}"
				if dpkg -s "plocate" > /dev/null 2>&1; then
			        echo -e "${C}[>] plocate is already installed!${N}"
			    else
			        if sudo apt install -y plocate > /dev/null 2>&1; then
			            if dpkg -s plocate > /dev/null 2>&1; then
			                echo -e "${G}[+] plocate installed successfully!${N}"
			            else
			                echo -e "${R}[-] Failed to verify plocate installation!${N}"
			                echo -e "${C}[>] Continuing...${N}"
			            fi
			        else
			            echo -e "${R}[-] Failed to install plocate!${N}"
			            echo -e "${C}[>] Continuing...${N}"
			        fi
			    fi
			else
				echo -e "${B}[*] Installing mlocate... ${N}"
				if dpkg -s "mlocate" > /dev/null 2>&1; then
			        echo -e "${C}[>] mlocate is already installed!${N}"
			    else
			        if sudo apt install -y mlocate > /dev/null 2>&1; then
			            if dpkg -s mlocate > /dev/null 2>&1; then
			                echo -e "${G}[+] mlocate installed successfully!${N}"
			            else
			                echo -e "${R}[-] Failed to verify mlocate installation!${N}"
			                echo -e "${C}[>] Continuing...${N}"
			            fi
			        else
			            echo -e "${R}[-] Failed to install mlocate!${N}"
			            echo -e "${C}[>] Continuing...${N}"
			        fi
			    fi
			fi

        elif [[ $key == "pip" ]]; then
            # Make sure python3-venv is installed
            if ! dpkg -s python3-venv > /dev/null 2>&1; then
                sudo apt install python3-venv -y
            fi

            sudo ln -s /usr/bin/python3 /usr/bin/python
            python3 -m venv ~/env
            sleep 3
            source ~/env/bin/activate
	    echo -e "${O}[*] Upgrading PIP${N}"
	    pip install --upgrade pip  > /dev/null 2>&1
     	    echo -e "${G}Done!${N}"

            echo -e "${O}[*] Installing packages with PIP${N}"
            install_pip ${ubuntu[$key]}
            sleep 3
            deactivate

        elif [[ $key == "snap" ]]; then
            echo -e "${O}[*] Installing packages with SNAP${N}"
            install_snap ${ubuntu[$key]}

        elif [[ $key == "git" ]]; then
            echo -e "${O}[*] Cloning GIT repositories${N}"
            cd ~/Git
            install_git ${ubuntu[$key]}
            cd
        fi
    done	

elif [[ $os_version == *"Debian"* ]]; then
	for key in "${order[@]}"; do
        if [[ $key == "apt" ]]; then
            echo -e "${O}[*] Installing packages with APT${N}"
            install_apt ${debian[$key]}
            export PATH=$PATH:/sbin
			source ~/.bashrc 
        elif [[ $key == "pip" ]]; then
            # Make sure python3-venv is installed
            if ! dpkg -s python3-venv > /dev/null 2>&1; then
                sudo apt install python3-venv -y
            fi

            sudo ln -s /usr/bin/python3 /usr/bin/python
            python3 -m venv ~/env
            sleep 3
            source ~/env/bin/activate
	    echo -e "${O}[*] Upgrading PIP${N}"
	    pip install --upgrade pip  > /dev/null 2>&1
     	    echo -e "${G}Done!${N}"
            echo -e "${O}[*] Installing packages with PIP${N}"
            install_pip ${debian[$key]}
            sleep 3
            deactivate

        elif [[ $key == "snap" ]]; then
            echo -e "${O}[*] Installing packages with SNAP${N}"
            install_snap ${debian[$key]}
            export PATH=$PATH:/snap/bin
			source ~/.bashrc

        elif [[ $key == "git" ]]; then
            echo -e "${O}[*] Cloning GIT repositories${N}"
            cd ~/Git
            install_git ${debian[$key]}
            cd
        fi
    done
else
	 echo -e "${R}[-] $os_version is not yet supported!${N}"
	 exit 1
fi

echo -e "${B}[*] Installing GO${N}"
wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz > /dev/null 2>&1
sudo tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz 
export PATH=$PATH:/usr/local/go/bin
source ~/.bashrc 
rm go1.23.2.linux-amd64.tar.gz
echo -e "${G}Done!${N}"

echo -e "${B}[*] Installing garble...${N}"
if go install mvdan.cc/garble@master > /dev/null 2>&1; then
	echo -e "${G}[+] garble installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install garble!${N}"
	echo -e "${C}[>] Continuing...${N}"
fi
cd ~/Git
cd NetExec
echo -e "${B}[*] Installing NetExec...${N}"
if sudo docker build -t netexec:latest . > /dev/null 2>&1; then
	if sudo docker run netexec --help > /dev/null 2>&1; then
		echo -e "${G}[+] netexec installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install netexec!${N}"
		echo -e "${C}[>] Continuing...${N}"
	fi
else
	echo -e "${R}[-] Failed to install netexec!${N}"
	echo -e "${C}[>] Continuing...${N}"	
fi
cd ..

cd nikto
echo -e "${B}[*] Installing nikto...${N}"
if sudo docker build -t sullo/nikto . > /dev/null 2>&1; then
	if sudo docker run --rm sullo/nikto -Version > /dev/null 2>&1; then
		echo -e "${G}[+] nikto installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install nikto!${N}"
		echo -e "${C}[>] Continuing...${N}"
	fi
else
	echo -e "${R}[-] Failed to install nikto!${N}"
	echo -e "${C}[>] Continuing...${N}"
fi
cd ..

cd ligolo-ng
echo -e "${B}[*] Installing ligolo proxy...${N}"
if go build -o lg-proxy cmd/proxy/main.go > /dev/null 2>&1; then
	sudo ln -s /home/$USER/Git/ligolo-ng/lg-proxy /usr/bin/lg-proxy
	echo -e "${G}[+] ligolo proxy installed successfully!${N}"
else
	echo -e "${R}[-] Failed to install ligolo proxy!${N}"
	echo -e "${C}[>] Continuing...${N}"
fi
cd ..

source ~/env/bin/activate
echo -e "${B}[*] Installing python package for${N} ${O}dnschef, adidnsdump, ADenum, ROADtools${N} ${B}tools${N}"
cd dnschef
pip install -r requirements.txt > /dev/null 2>&1
cd ..
cd adidnsdump
pip install . > /dev/null 2>&1
cd ..
cd ADenum
pip install -r requirements.txt > /dev/null 2>&1
cd ..
cd ROADtools/
pip install . > /dev/null 2>&1
cd 
echo -e "${G}[+] Done!${N}"
deactivate

cd ~/Tools
mkdir routes
cd routes
echo -e "${B}[*] Downloading 'routes' tool of @Andre Marques...${N}"
wget https://raw.githubusercontent.com/VitoBonetti/c2-setup/refs/heads/main/routes/configure_routes.sh > /dev/null 2>&1
wget https://raw.githubusercontent.com/VitoBonetti/c2-setup/refs/heads/main/routes/ipparser.py > /dev/null 2>&1
cd
echo -e "${G}[+] Done!${N}"

echo -e "${B}[*] Installing manspider...${N}"
if sudo docker pull blacklanternsecurity/manspider > /dev/null 2>&1; then
	if sudo docker run blacklanternsecurity/manspider --help > /dev/null 2>&1; then
		echo -e "${G}[+] maspider installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install manspider!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install manspider!${N}"
	echo "[>] Continuing..."
fi


echo -e "${B}[*] Installing gowitness...${N}"
if sudo docker pull leonjza/gowitness > /dev/null 2>&1; then
	if sudo docker run --rm leonjza/gowitness gowitness > /dev/null 2>&1; then
		echo -e "${G}[+] gowitness installed successfully!${N}"
	else
		echo -e "${R}[-] Failed to install gowitness!${N}"
		echo "[>] Continuing..."
	fi
else
	echo -e "${R}[-] Failed to install gowitness!${N}"
	echo "[>] Continuing..."
fi

echo -e "${B}[*] Create ligolo TUN adapter for the tunnel...${N}"
sudo ip tuntap add user "$USER" mode tun ligolo
sudo ip link set ligolo up
if ifconfig ligolo > /dev/null 2>&1; then
	echo -e "${G}[+] ligolo TUN adapter created successfully!${N}"
	echo -e "${O}"
	echo "[!] You need to add a new route to the ligolo TUN adapter."
	echo "[!] You  need to bind the Domain controller IP address to the name in the /etc/hosts file."
	echo "[!] This it will change depending from the target."
	echo -e "${N}"
else
	echo -e "${R}[-] Failed to create ligolo TUN adapter!${N}"
	echo -e "${C}[>] Continuing...${N}"
fi

echo -e "${B}[*] Installing SecLists...${N}"
sudo mkdir /usr/share/wordlists
vito@debian:~$ 

cd /usr/share/wordlists
if sudo git clone https://github.com/danielmiessler/SecLists.git > /dev/null 2>&1; then
	cd
	sudo chmod 755 /usr/share/wordlists
	sudo chmod -R a+r /usr/share/wordlists
	sudo find /usr/share/wordlists -type d -exec chmod 755 {} \;
	echo -e "${G}Done!${N}"
else
	echo -e "${R}[-] Failed to clone  SecLists repository !${N}"
	echo -e "${C}[>] Continuing...${N}"
fi

echo -e "${B}[*] Updating Database...${N}"
sudo updatedb
echo -e "${G}[+] Database successfully updated...${N}"
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${G}[+] Done${N}"
echo -e "${0}[+] Execution time: $execution_time seconds${N}"
echo -e "${P}[#] Bye Bye $USER have a great hacking time!${N}"
exit 0

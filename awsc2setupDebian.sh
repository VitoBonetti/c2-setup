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

# Function to install a package if not already installed
install_package() {
    local package=$1
    echo -e "${B}[*] Installing ${package}...${N}"
    if is_installed "${package}"; then
        echo -e "${G}[+] ${package} is already installed!${N}"
    else
        if sudo apt install -y "${package}"; then
            if command -v "${package}" &> /dev/null; then
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
cat << EOF | sudo tee /etc/apt/preferences.d/unstable
Package: *
Pin: release a=unstable
Pin-Priority: 50
EOF
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade
cat /etc/apt/sources.list.d/deb-multimedia.list
cat /etc/apt/sources.list.d/backports.list
cat /etc/apt/sources.list.d/unstable.list
sudo tee /etc/apt/preferences.d/unstable > /dev/null << 'EOF'
Package: *
Pin: release a=unstable
Pin-Priority: 50
EOF
sudo tee /etc/apt/preferences.d/bookworm > /dev/null << 'EOF'
Package: *
Pin: release a=bookworm
Pin-Priority: 900
cat /etc/apt/sources.list.d/*
apt list --upgradable
echo -e "${G}[+] Package sources update successfully!${N}"

echo -e "${B}[*] Updating the system...${N}"
if sudo apt update -y; then
	echo -e "${G}[+] System update successfully!${N}"
else
	echo -e "${R}[-] Failed to update the system!${N}"
fi

echo -e "${B}[*] Upgrading the system...${N}"
if sudo apt upgrade -y; then
	echo -e "${G}[+] System upgraded successfully!${N}"
else
	echo -e "$[-] {R}Failed to upgrade the system!${N}"
fi

# Create persistence on the /tmp folder

echo -e "${B}[*] Make the /tmp folder persistence...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "${G}[+] Done!${N}"

# Install Python virtual environment and create 2 enviroment, high and low privilage in the /opt and /tmp folder


sudo apt install -y python3-venv
if dpkg -l | grep python3-venv; then
	echo -e "${G}[+] python3-venv installed successfully!${N}"
else
    echo -e "${R}[-] Failed to verify python3-venv installation!${N}"
     echo "[>] Continuing..."
fi
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

sudo apt install -y net-tools
sudo ln -s /sbin/ifconfig /usr/local/bin/ifconfig
if dpkg -l | grep net-tools; then
	echo -e "${G}[+] net-tools installed successfully!${N}"
else
    echo -e "${R}[-] Failed to verify net-tools installation!${N}"
     echo "[>] Continuing..."
fi

sudo apt install -y net-tools
sudo ln -s /sbin/ifconfig /usr/local/bin/ifconfig
if dpkg -l | grep net-tools; then
	echo -e "${G}[+] net-tools installed successfully!${N}"
else
    echo -e "${R}[-] Failed to verify net-tools installation!${N}"
     echo "[>] Continuing..."
fi
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
install_package "snapd"
if sudo snap install go --classic; then
	sudo ln -s /snap/go/current/bin/go /usr/local/bin/go
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

echo -e "${B}[*] Installing ligolo proxy...${N}"
cd /opt
sudo git clone https://github.com/0x00-0x00/ligolo-ng
cd ligolo-ng
sudo go build -o proxy cmd/proxy/main.go
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


end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${0}"
echo "[+] Done"
echo "[+] Execution time: $execution_time seconds"
echo -e "${N}"

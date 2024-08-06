#!/bin/bash

# Declaring the colors
G="\033[0;32m"  # GREEN
B="\033[0;34m"  # BLUE
O="\033[0;33m"  # ORANGE
Y="\033[1;33m"  # YELLOW
R="\033[0;31m"  # RED
N="\033[0m"     # No Color / Reset
P="\033[35m"    # PURPLE Troubleshoot color

current_user=$USER
py_venv_path="/home/${current_user}/env/bin/activate"

git_array=("https://github.com/Pennyw0rth/NetExec" "https://github.com/sullo/nikto.git" "https://github.com/0x00-0x00/ligolo-ng"  "https://github.com/iphelix/dnschef.git" "https://github.com/GoSecure/ldap-scanner.git" "https://github.com/dirkjanm/adidnsdump" "https://github.com/VitoBonetti/ADenum.git" "https://github.com/ozguralp/gmapsapiscanner.git")
apt_development_array=("apt-utils" "build-essential" "libsasl2-dev" "python3-dev" "libldap2-dev" "libssl-dev" "net-tools" "python3-venv" "mlocate")
debian_array=("snapd" "git" "python3-venv")
apt_packages_array=("apache2" "docker.io" "hashcat" "hydra-gtk" "gobuster" "dirb" "hping3" "john" "cewl" "smbmap" "whatweb" "sendemail" "ruby-dev" "socat" "wine64")
snap_packages_array=("go" "nmap" "rustscan" "sqlmap" "enum4linux" "powershell")
pip_packages_array=("setuptools" "wheel" "lxml==4.9.3" "certipy-ad" "kerbrute" "bloodhound" "impacket")

activate_python_venv() {
  if [[ -z "$VIRTUAL_ENV" ]]; then
    source "$py_venv_path"
    if [[ -z "$VIRTUAL_ENV" ]]; then
       echo -e "${R}[-] Failed to activate Python virtual environment!${N}"
    else
      echo -e "${G}[+] Python virtual environment activated: $VIRTUAL_ENV${N}"
    fi
  else
    echo -e "${G}[+] Virtual environment is active: $VIRTUAL_ENV${N}"
  fi
}

install_pip() {
  local package=$1
  echo -e "${O}[*] Installing python ${package}...${N}"
  if pip install "${package}" > /dev/null 2>&1; then
    echo -e "${G}[+] ${package} successfully installed!${N}"
  else
     echo -e "${R}[-] Failed to install ${package} python package!${N}"
     echo -e "${B}[>] Continuing...${N}"
  fi
}

install_apt() {
  local package=$1
  echo -e "${O}[*] Installing ${package}...${N}"
  if dpkg -s "${package}" > /dev/null 2>&1; then
    echo -e "${G}[+] ${package} is already installed!${N}"
  else
    if sudo apt install -y "${package}" > /dev/null 2>&1; then
        echo -e "${G}[+] ${package} installed successfully!${N}"
    else
        echo -e "${R}[-] Failed to install ${package}!${N}"
        echo -e "${B}[>] Continuing...${N}"
    fi
  fi
}

install_snap() {
    local package=$1
    echo -e "${O}[*] Installing ${package}...${N}"
    if snap list | grep "$package" > /dev/null 2>&1; then
      echo -e "${G}[+] ${package} is already installed!${N}"
    else
      if sudo snap install "${package}" --classic > /dev/null 2>&1; then
        if snap list | grep "$package" > /dev/null 2>&1; then
          echo -e "${G}[+] ${package} installed successfully!${N}"
        else
          echo -e "${R}[-] Failed to verify ${package} installation!${N}"
          echo -e "${B}[>] Continuing...${N}"
        fi
      else
        echo -e "${R}[-] Failed to install ${package}!${N}"
        echo -e "${B}[>] Continuing...${N}"
      fi
    fi
}

install_git () { 
	local repository=$1 
	echo -e "${O}[*] Cloning ${repository} repository...${N}" 
	if git clone "${repository}" > /dev/null 2>&1; then 
		echo -e "${G}[+] ${repository} successfully cloned!${N}" 
	else 
		echo -e "${R}[-] Failed to clone ${repository} repository!${N}" 
		echo -e "${B}[>] Continuing...${N}" 
	fi 
}

update_system() {
  echo -e "${O}Updating the system...${N}"
  if sudo apt update -y > /dev/null 2>&1; then
    echo -e "${G}System update successfully!${N}"
  else
    echo -e "${R}Failed to update the system!${N}"
  fi
}

upgrade_system() {
  echo -e "${B}Upgrading the system...${N}"
  if sudo apt upgrade -y > /dev/null 2>&1; then
    echo -e "${G}System upgraded successfully!${N}"
  else
    echo -e "${R}Failed to upgrade the system!${N}"
  fi
}

is_active() {
  local service=$1
  if sudo systemctl is-active --quiet "${service}"; then
    echo -e "${G}[+] ${service} is up and running!${N}"
  else
    echo -e "${O}[*] Starting up ${service} service..${N}"
    if sudo systemctl start "${service}"; then
      echo -e "${G}[+] ${service} is up and running!${N}"
    else
      echo -e "${R}[-] Failed to start ${service} service!${N}"
      echo -e "${B}[>] Continuing...${N}"
    fi
  fi
}

echo -e "${O}[*] Determining linux distribution...${N}"
DESCRIPTION=$(lsb_release -d | awk -F'\t' '{print $2}')
echo -e "${G}[+] ${DESCRIPTION} ${N}"

update_system
upgrade_system

echo -e "${O}[*] Making the /tmp folder persistent...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf > /dev/null
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf > /dev/null
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Creating Git folder in '/home/${current_user}'...${N}"
if [ ! -d "$HOME/Git" ]; then
  mkdir "$HOME/Git"
fi
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing development tools...${N}"
for package in "${apt_development_array[@]}"; do
  install_apt "$package"
done
echo -e "${G}[+] Done!${N}"

sudo ln -s /usr/bin/python3 /usr/bin/python

if [[ $DESCRIPTION == *Debian* ]]; then
  for package in "${debian_array[@]}"; do
    install_apt "$package"
  done
fi
export PATH=$PATH:/snap/bin:/usr/bin/snap
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Creating Python virtual environment.${N}"
if python3 -m venv env; then
  sleep 5
  echo -e "${G}[+] Python virtual environment created successfully at '/home/${current_user}/env'.${N}"
else
  echo -e "${R}[-] Failed to create Python virtual environment!${N}"
  echo -e "${B}[>] Continuing...${N}"
fi

echo -e "${O}[*] Installing python packages...${N}"
activate_python_venv
for package in "${pip_packages_array[@]}"; do
  install_pip "${package}"
done
deactivate
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing tools with APT...${N}"
for package in "${apt_packages_array[@]}"; do
  install_apt "$package"
done
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing tools with SNAP...${N}"
for package in "${snap_packages_array[@]}"; do
  install_snap "$package"
done
echo -e "${G}[+] Done!${N}"

echo -e "${B}[*] Installing garble...${N}"
if go install mvdan.cc/garble@latest; then
    echo -e "${G}[+] garble installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install garble!${N}"
    echo "[>] Continuing..."
fi

cd "$HOME/Git"
echo -e "${O}[*] Cloning repositories from GIT...${N}"

echo -e "${O}[*] Cloning ligolo agent repository...${N}" 
if git clone https://github.com/nicocha30/ligolo-ng ligolo-agent > /dev/null 2>&1; then 
	echo -e "${G}[+] Ligolo agent successfully cloned!${N}" 
else 
	echo -e "${R}[-] Failed to clone Ligolo agent repository!${N}" 
	echo -e "${B}[>] Continuing...${N}" 
fi 

for rep in "${git_array[@]}"; do
  install_git "$rep"
done
echo -e "${G}[+] Done!${N}"

cd NetExec || { echo -e "${R}[-] Failed to navigate to NetExec directory!${N}"; exit 1; }
echo -e "${B}[*] Installing NetExec...${N}"
sudo docker build -t netexec:latest .
if sudo docker run netexec --help > /dev/null 2>&1; then
    echo -e "${G}[+] netexec installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install netexec!${N}"
    echo "[>] Continuing..."
fi
cd ..

cd nikto || { echo -e "${R}[-] Failed to navigate to nikto directory!${N}"; exit 1; }
echo -e "${B}[*] Installing nikto...${N}"
sudo docker build -t sullo/nikto .
if sudo docker run --rm sullo/nikto -Version > /dev/null 2>&1; then
    echo -e "${G}[+] nikto installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install nikto!${N}"
    echo "[>] Continuing..."
fi
cd ..

echo -e "${B}[*] Installing manspider...${N}"
sudo docker pull blacklanternsecurity/manspider
if sudo docker run blacklanternsecurity/manspider --help > /dev/null 2>&1; then
  echo -e "${G}[+] manspider installed successfully!${N}"
else
  echo -e "${R}[-] Failed to install manspider!${N}"
  echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing gowitness...${N}"
sudo docker pull leonjza/gowitness
if sudo docker run --rm leonjza/gowitness gowitness > /dev/null 2>&1; then
  echo -e "${G}[+] gowitness installed successfully!${N}"
else
  echo -e "${R}[-] Failed to install gowitness!${N}"
  echo "[>] Continuing..."
fi

cd ligolo-ng || { echo -e "${R}[-] Failed to navigate to ligolo-ng directory!${N}"; exit 1; }
if go build -o lg-proxy cmd/proxy/main.go; then
  sudo ln -s "$HOME/Git/ligolo-ng/lg-proxy" /usr/bin/lg-proxy
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
else
  echo -e "${R}"
  echo "[-] Failed to build ligolo proxy!"
  echo "[-] The script can't continue."
  echo "[-] Terminating.."
  echo -e "${N}"
  exit 1
fi
cd ..

activate_python_venv
cd dnschef || { echo -e "${R}[-] Failed to navigate to dnschef directory!${N}"; exit 1; }
echo -e "${O}[*] Installing dnschef dependencies...${N}"
pip install -r requirements.txt
cd ..

cd adidnsdump || { echo -e "${R}[-] Failed to navigate to adidnsdump directory!${N}"; exit 1; }
echo -e "${O}[*] Installing adidnsdump dependencies...${N}"
pip install .
cd ..

cd ADenum || { echo -e "${R}[-] Failed to navigate to ADenum directory!${N}"; exit 1; }
echo -e "${O}[*] Installing ADenum dependencies...${N}"
pip install -r requirements.txt
cd ..

deactivate

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "${G}[+] Done${N}"
echo -e "${0}[+] Execution time: $execution_time seconds${N}"

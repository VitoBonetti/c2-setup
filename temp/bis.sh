#!/bin/bash

# Declaring the colors
G="\033[0;32m"  # GREEN
B="\033[0;34m"  # BLUE
O="\033[0;33m"  # ORANGE
Y="\033[1;33m"  # YELLOW
R="\033[0;31m"  # RED
N="\033[0m"     # No Color / Reset
P="\e[35m"      # PURPLE Troubleshoot color

current_user=$USER
py_venv_path="/home/${current_user}/env/bin/activate"

git_array=("https://github.com/Pennyw0rth/NetExec" "https://github.com/sullo/nikto.git" "https://github.com/0x00-0x00/ligolo-ng" "https://github.com/nicocha30/ligolo-ng ligolo-agent" "https://github.com/iphelix/dnschef.git" "https://github.com/GoSecure/ldap-scanner.git" "https://github.com/dirkjanm/adidnsdump" "https://github.com/VitoBonetti/ADenum.git" "https://github.com/ozguralp/gmapsapiscanner.git")
apt_development_tools=("build-essential" "libsasl2-dev"  "python3-dev"  "libldap2-dev" "libssl-dev" "net-tools" "python3-venv")
apt_packages=("snapd" "git" "apache2" "docker.io" "hashcat" "hydra-gtk" "gobuster" "dirb" "hping3" "john" "cewl" "smbmap" "whatweb" "sendemail"  "ruby-dev" "socat" "wine64")
snap_packages=("go" "nmap" "rustscan" "sqlmap" "enum4linux" "powershell")
pip_packages=("wheel" "lxml==4.9.3" "setuptools" "certipy-ad" "kerbrute" "bloodhound" "impacket")

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

install_apt() {
  local package=$1
  echo -e "${O}[*] Installing ${package}...${N}"
  if dpkg -s "${package}" > /dev/null 2>&1; then
    echo -e "${G}[+] ${package} is already installed!${N}"
  else
    if sudo apt install -y "${package}" > /dev/null 2>&1; then
      if dpkg -s "${package}" > /dev/null 2>&1; then
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
            echo -e "${B}[>] Continuing...${N}"
          fi
        else
          echo -e "${R}[-] Failed to install ${package}!${N}"
          echo -e "${B}[>] Continuing...${N}"
        fi
      fi
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

check_and_upgrade_ruby() {
    required_ruby_version="3.0.0"
    current_ruby_version=$(ruby -v | awk '{print $2}')
    echo -e "${O}[*] Current Ruby version: ${current_ruby_version}${N}"
    if [ "$(printf '%s\n' "$required_ruby_version" "$current_ruby_version" | sort -V | head -n1)" != "$required_ruby_version" ]; then
        echo -e "${G}[+] Ruby is up to date!${N}"
    else
        echo -e "${O}[*] Upgrading Ruby to version ${required_ruby_version}...${N}"
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:brightbox/ruby-ng
        sudo apt update
        sudo apt install -y ruby${required_ruby_version}
        echo -e "${G}[+] Ruby upgraded to version $(ruby -v | awk '{print $2}')${N}"
    fi

    echo -e "${O}[*] Updating RubyGems...${N}"
    sudo gem update --system
    echo -e "${G}[+] RubyGems updated to version $(gem --version)${N}"
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

# Starting the script
start_time=$(date +%s)

echo -e "${B}"
echo "[+] C2 Setup"
echo "[*] Starting the process..."
echo -e "${N}"

echo -e "${O}[*] Determining linux distribution...${N}"

DESCRIPTION=$(lsb_release -d | awk -F'\t' '{print $2}')

echo -e "${G}[+] ${DESCRIPTION} ${N}"
update_system
upgrade_system
check_and_upgrade_ruby

echo -e "${O}[*] Making the /tmp folder persistent...${N}"
sudo touch /etc/tmpfiles.d/tmp.conf
echo "# Disable automatic cleanup of /tmp" | sudo tee /etc/tmpfiles.d/tmp.conf
echo "d /tmp 1777 root root -" | sudo tee -a /etc/tmpfiles.d/tmp.conf
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Creating Git folder in '/home/${current_user}'... ${N}"
mkdir Git
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing development tools...${N}"
for package in "${apt_development_tools[@]}"; do
  install_apt "$package"
done
echo -e "${G}[+] Done!${N}"

sudo ln -s /usr/bin/python3 /usr/bin/python

echo -e "${O}[*] Creating Python virtual environment.${N}"
if python -m venv env; then
  sleep 5
  echo -e "${G}[+] Python virtual environment created successfully at '/home/${current_user}/env'.${N}"
else
  echo -e "${R}[-] Failed to create Python virtual environment!${N}"
  echo -e "${B}[>] Continuing...${N}"
fi

echo -e "${O}[*] Installing python packages...${N}"
activate_python_venv
for package in "${pip_packages[@]}"; do
  install_pip "${package}"
done
deactivate
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing tools with APT...${N}"
for package in "${apt_packages[@]}"; do
  install_apt "$package"
done
echo -e "${G}[+] Done!${N}"

echo -e "${O}[*] Installing tools with GEMS...${N}"
if sudo gem install wpscan; then
    echo -e "${G}[+] wpscan successfully installed!${N}"
else
    echo -e "${R}[-] Failed to install wpscan!${N}"
    echo "[>] Continuing..."
fi
echo -e "${G}[+] Done! ${N}"

echo -e "${O}[*] Installing tools with SNAP...${N}"
for package in "${snap_packages[@]}"; do
  install_snap "$package"
done
echo -e "${G}[+] Done! ${N}"

echo -e "${B}[*] Installing garble...${N}"
if go install mvdan.cc/garble@master; then
    echo -e "${G}[+] garble installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install garble!${N}"
    echo "[>] Continuing..."
fi

cd Git
echo -e "${O}[*] Cloning repositories from GIT...${N}"
for rep in "${git_array[@]}"; do
  install_git "$rep"
done
echo -e "${G}[+] Done! ${N}"

cd NetExec
echo -e "${B}[*] Installing NetExec...${N}"
sudo docker build -t netexec:latest .
if sudo docker run netexec --help > /dev/nul 2>&1; then
    echo -e "${G}[+] netexec installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install netexec!${N}"
    echo "[>] Continuing..."
fi
cd ..

cd nikto
echo -e "${B}[*] Installing nikto...${N}"
sudo docker build -t sullo/nikto .
if sudo docker run --rm sullo/nikto -Version > /dev/nul 2>&1; then
    echo -e "${G}[+] nikto installed successfully!${N}"
else
    echo -e "${R}[-] Failed to install nikto!${N}"
    echo "[>] Continuing..."
fi
cd ..

echo -e "${B}[*] Installing manspider...${N}"
sudo docker pull blacklanternsecurity/manspider
if sudo docker run blacklanternsecurity/manspider --help > /dev/nul 2>&1; then
  echo -e "${G}[+] maspider installed successfully!${N}"
else
  echo -e "${R}[-] Failed to install manspider!${N}"
  echo "[>] Continuing..."
fi

echo -e "${B}[*] Installing gowitness...${N}"
sudo docker pull leonjza/gowitness
if sudo docker run --rm leonjza/gowitness gowitness > /dev/nul 2>&1; then
  echo -e "${G}[+] gowitness installed successfully!${N}"
else
  echo -e "${R}[-] Failed to install gowitness!${N}"
  echo "[>] Continuing..."
fi

cd ligolo-ng
if go build -o lg-proxy cmd/proxy/main.go; then
  sudo ln -s /home/$current_user/Git/ligolo-ng/lg-proxy /usr/bin/lg-proxy
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
cd dnschef
echo -e "${O}[*] Installing dnschef dependencies...${N}"
pip install -r requirements.txt
cd ..

cd adidnsdump
echo -e "${O}[*] Installing adidnsdump dependencies...${N}"
pip install .
cd ..

cd ADenum
echo -e "${O}[*] Installing ADenum dependencies...${N}"
pip install -r requirements.txt
cd

deactivate

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



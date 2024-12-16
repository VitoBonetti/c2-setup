# C2 Environment Setup Script

This repository contains a Bash script designed to streamline the setup and deployment of a Ligolo-based Command and Control (C2) environment, along with various offensive security and reconnaissance tools. It is intended for use during adversary simulation tests, penetration tests, and red team exercises.

## Overview

The provided script automates the installation and configuration of a wide range of tools commonly used in cybersecurity operations. It detects whether you are running on Ubuntu or Debian, updates the system, installs system packages, sets up Python virtual environments, fetches repositories, and configures services for offensive operations.

Key features include:

- Automated installation of system packages via APT and SNAP.
- Installation of Python packages into a dedicated virtual environment.
- Cloning and setting up offensive security tools from Git repositories.
- Configuring a persistent `/tmp` directory.
- Setting up and configuring Docker images and containers for certain tools.
- Installing Go and related tools (such as `garble`).
- Preparing a TUN interface for Ligolo C2 tunneling.
- Providing a unified environment ready for adversary emulation exercises.

## Tested Operating Systems

- **Ubuntu:** Verified on Ubuntu variants. Specific handling for Ubuntu 24.04 and earlier versions regarding the `mlocate` and `plocate` packages.
- **Debian:** Basic support with installation of `snapd` and other Debian-compatible packages.

**Note:** Other distributions are not currently supported by this script and may fail.

## Tools Installed

Below is a categorized list of all tools and packages the script installs.

### APT Packages

For Ubuntu:
- `build-essential`
- `libsasl2-dev`
- `python3-dev`
- `libldap2-dev`
- `libssl-dev`
- `net-tools`
- `libreadline-dev`
- `zlib1g-dev`
- `gnupg2`
- `python3-venv`
- `nmap`
- `apache2`
- `docker.io`
- `hashcat`
- `hydra-gtk`
- `gobuster`
- `dirb`
- `hping3`
- `john`
- `cewl`
- `smbmap`
- `whatweb`
- `sendemail`
- `socat`
- `wine64`
  
For Debian (includes the above and adds):
- `git`
- `snapd`
- `plocate` (for Debian or Ubuntu 24.04) / `mlocate` (for other Ubuntu versions)

The script automatically determines whether to install `plocate` or `mlocate` based on the OS version.

### SNAP Packages

- `sqlmap`
- `enum4linux`

### Python Packages (via PIP)

All Python packages are installed into a Python virtual environment (`~/env`):

- `wheel`
- `pyOpenSSL==24.0.0`
- `lxml==4.9.3`
- `setuptools`
- `certipy-ad`
- `kerbrute`
- `bloodhound`
- `impacket`

Additional Python dependencies for the cloned Git repositories are installed later.

### Git Repositories

All repositories are cloned into `~/Git`:

- [NetExec](https://github.com/Pennyw0rth/NetExec)
- [Nikto](https://github.com/sullo/nikto.git)
- [Ligolo-NG](https://github.com/0x00-0x00/ligolo-ng)
- [DNSChef](https://github.com/iphelix/dnschef.git)
- [LDAP-Scanner](https://github.com/GoSecure/ldap-scanner.git)
- [ADIDNSDump](https://github.com/dirkjanm/adidnsdump)
- [ADenum](https://github.com/VitoBonetti/ADenum.git)
- [Gmapsapiscanner](https://github.com/ozguralp/gmapsapiscanner.git)
- [inflate.py](https://github.com/njcve/inflate.py)
- [ROADtools](https://github.com/dirkjanm/ROADtools.git)

### Docker Images

- **NetExec**: Built locally with `docker build -t netexec:latest .` inside the `NetExec` directory.
- **Nikto**: Built locally from the `nikto` directory (`docker build -t sullo/nikto .`).
- **Manspider**: Pulled from [BlackLanternSecurity/manspider](https://hub.docker.com/r/blacklanternsecurity/manspider).
- **Gowitness**: Pulled from [leonjza/gowitness](https://hub.docker.com/r/leonjza/gowitness).

### Go and Go-Based Tools

- **Go**: Installed from `go1.23.2.linux-amd64.tar.gz` (official Go release).
- **Garble**: Installed using `go install mvdan.cc/garble@master`.
  
### Additional Security Tools

- **SecLists**: Cloned into `/usr/share/wordlists/SecLists`.
- **Ligolo-NG Proxy**: Compiled from the `ligolo-ng` repository and linked to `/usr/bin/lg-proxy`.
- **DNSChef, ADIDNSDump, ADenum, ROADtools**: Required Python dependencies installed after cloning.

### Networking Setup

- Creates a `ligolo` TUN adapter for Ligolo-based tunneling:  
  ```bash
  sudo ip tuntap add user "$USER" mode tun ligolo
  sudo ip link set ligolo up
  ```
  
  **Note:** After the script finishes, you will need to manually add routes and modify `/etc/hosts` as necessary to map target domain controllers or other hosts to the TUN interface.

### Custom Scripts and Routes

- Downloads a `routes` configuration script (`configure_routes.sh` and `ipparser.py`) into `~/Tools/routes/`.

### Final Steps

- Updates the system database using `updatedb` for easy file location via `locate`.

## Prerequisites

- **Root or Sudo Access:** The script must be run with privileges that allow system changes (e.g., `sudo`).
- **Internet Connection:** A stable internet connection is required to download packages, clone repositories, and pull Docker images.
- **Compatible OS:** Ubuntu (various versions) or Debian are currently supported.

## Installation & Usage

1. **Clone this repository:**
   ```bash
   wget https://raw.githubusercontent.com/VitoBonetti/c2-setup/refs/heads/main/multiplatform.sh
   ```

2. **Make the script executable:**
   ```bash
   chmod +x multiplatform.sh
   ```

3. **Run the script:**
   ```bash
   ./multiplatform.sh
   ```
   
   The script will:
   - Detect your OS (Ubuntu or Debian).
   - Update and upgrade system packages.
   - Install the specified APT, SNAP, and PIP packages.
   - Set up a Python virtual environment.
   - Clone various Git repositories containing offensive security tools.
   - Install Docker images for certain tools (NetExec, Nikto, Manspider, Gowitness).
   - Install Go and the `garble` obfuscation tool.
   - Configure the Ligolo TUN adapter.
   - Clone and set permissions for SecLists.
   - Update the system’s `locate` database.

4. **Post-Installation Steps:**
   - Check the `ligolo` TUN adapter: `ifconfig ligolo`.
   - Add necessary routes and hosts to `/etc/hosts` as your testing scenario requires.
   - Activate the Python virtual environment as needed:
     ```bash
     source ~/env/bin/activate
     ```
     and deactivate with:
     ```bash
     deactivate
     ```
   - Tools installed via Docker can be run with `sudo docker run ...`.

## Troubleshooting

- **Missing Dependencies:** If the script fails due to missing dependencies, ensure `sudo` privileges and a stable network connection.
- **Unsupported Distribution:** The script may fail if run on unsupported distributions or significantly different OS versions.
- **Manual Adjustments:** Some packages or tools may require manual configuration post-installation. Check the official documentation for each tool if you encounter issues.

## Contributing

Contributions are welcome! If you have suggestions, improvements, or encounter issues:

1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request describing your modifications.

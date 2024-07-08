# C2 Setup for Adversary Simulation Test

## gpcc2setup.sh 

Optimize for Ubuntu 20.04 LTS on Google Cloud Platform

## awsc2setup.sh 

Optimize for Ubuntu 24.04 LTS on a EC2 - AWS

## awsc2setupDebian.sh

This script has been optimized and tested for run on a AWS EC2 Debian instances.

#### *EC2 Instances image*

- **Debian 12 (HVM)**, SSD Volume Type<br>
  **ami-0983f1f9ba9026e4e (64-bit (x86))**<br>
  Debian 12 (HVM), EBS General Purpose (SSD) Volume Type. Community developed free GNU/Linux distribution. https://www.debian.org/
- Type: **t2.micro** 

#### *EC2 Instances basic set up*

- **Access**: Access via key pair
- **Firewall**: SSH, HTTP, HTTPS allowed
- **Storage**: 40 GB

#### Running the script

```
wget https://raw.githubusercontent.com/VitoBonetti/c2-setup/main/awsc2setupDebian.sh
chmod +x awsc2setupDebian.sh
./awsc2setupDebian.sh
```
When the script is done update the ***/etc/profile*** and the ***/etc/bash.bashrc***

```
source /etc/profile
source /etc/bash.bashrc
```
#### Knows issues

- ...

#### To Do

- ...

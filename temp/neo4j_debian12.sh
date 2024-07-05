#!/bin/bash

wget -qO - https://repos.azul.com/azul-repo.key | gpg --dearmor | sudo tee /usr/share/keyrings/azulsystems-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/azulsystems-archive-keyring.gpg] https://repos.azul.com/zulu/deb/ stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
sudo apt update -y
sudo apt install zulu-11 -y
java -version
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.com stable 4.4' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt update -y
sudo apt install neo4j -y
sudo neo4j start --verbose
sudo neo4j status
sudo neo4j console --verbose

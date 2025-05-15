#!/bin/bash
# Complete Minecraft Interactive Menu for WISP
# Supports: Java (Vanilla/Paper/Spigot/Fabric) + Bedrock (Vanilla/PocketMine/Nukkit)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation functions
install_java() {
  clear
  echo -e "${BLUE}=== Java Edition Installation ===${NC}"
  echo "1) Vanilla (Official)"
  echo "2) Paper (Optimized)"
  echo "3) Spigot (Plugins)"
  echo "4) Fabric (Mods)"
  read -p "Choose software (1-4): " choice

  case $choice in
    1) type="vanilla";;
    2) type="paper";;
    3) type="spigot";;
    4) type="fabric";;
    *) echo -e "${RED}Invalid choice!${NC}"; return;;
  esac

  echo -e "${YELLOW}Fetching versions...${NC}"
  case $type in
    vanilla)
      versions=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.versions[] | select(.type == "release") | .id' | head -n 10)
      ;;
    paper)
      versions=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[]' | tail -n 10)
      ;;
    spigot)
      versions=$(curl -s https://hub.spigotmc.org/versions/ | grep -oP '1\.[0-9]+\.[0-9]+' | sort -u | tail -n 10)
      ;;
    fabric)
      versions=$(curl -s https://meta.fabricmc.net/v2/versions/game | jq -r '.[].version' | head -n 10)
      ;;
  esac

  echo -e "\n${GREEN}Available versions:${NC}"
  echo "$versions"
  read -p "Enter version: " version

  echo -e "${YELLOW}Installing $type $version...${NC}"
  cd /mnt/server
  rm -rf *

  case $type in
    vanilla)
      url=$(curl -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r ".versions[] | select(.id == \"$version\") | .url")
      wget -O server.jar "$(curl -s "$url" | jq -r '.downloads.server.url')"
      ;;
    paper)
      build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$version" | jq -r '.builds[-1]')
      wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$version/builds/$build/downloads/paper-$version-$build.jar"
      ;;
    spigot)
      wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
      java -jar BuildTools.jar --rev "$version" > /dev/null
      mv spigot-*.jar server.jar
      rm BuildTools.jar
      ;;
    fabric)
      installer=$(curl -s "https://meta.fabricmc.net/v2/versions/installer" | jq -r '.[0].url')
      wget -O fabric-installer.jar "$installer"
      java -jar fabric-installer.jar server -mcversion "$version" -downloadMinecraft > /dev/null
      mv fabric-server-launch.jar server.jar
      rm fabric-installer.jar
      ;;
  esac

  echo "eula=true" > eula.txt
  echo -e "${GREEN}Java server installed!${NC}"
  sleep 2
}

install_bedrock() {
  clear
  echo -e "${BLUE}=== Bedrock Edition Installation ===${NC}"
  echo "1) Vanilla (Official)"
  echo "2) PocketMine (PHP)"
  echo "3) Nukkit (Java)"
  read -p "Choose software (1-3): " choice

  case $choice in
    1) type="vanilla";;
    2) type="pocketmine";;
    3) type="nukkit";;
    *) echo -e "${RED}Invalid choice!${NC}"; return;;
  esac

  cd /mnt/server
  rm -rf *

  case $type in
    vanilla)
      echo -e "${YELLOW}Downloading Bedrock server...${NC}"
      wget -O bedrock.zip "$(curl -s https://www.minecraft.net/en-us/download/server/bedrock | grep -oP 'https://[^"]+bin-linux[^"]+')"
      unzip bedrock.zip
      rm bedrock.zip
      ;;
    pocketmine)
      echo -e "${YELLOW}Installing PocketMine...${NC}"
      apt-get install -y php
      wget -O PocketMine-MP.phar https://github.com/pmmp/PocketMine-MP/releases/latest/download/PocketMine-MP.phar
      ;;
    nukkit)
      echo -e "${YELLOW}Downloading Nukkit...${NC}"
      wget -O server.jar https://ci.opencollab.dev/job/NukkitX/job/Nukkit/job/master/lastSuccessfulBuild/artifact/target/nukkit-1.0-SNAPSHOT.jar
      ;;
  esac

  echo -e "${GREEN}Bedrock server installed!${NC}"
  sleep 2
}

start_server() {
  cd /mnt/server
  if [ -f "server.jar" ]; then
    echo -e "${YELLOW}Starting Java server...${NC}"
    java -Xms1G -Xmx$(free -m | awk '/Mem:/ {print int($2*0.85)}')M -jar server.jar nogui
  elif [ -f "bedrock_server" ]; then
    echo -e "${YELLOW}Starting Bedrock server...${NC}"
    LD_LIBRARY_PATH=. ./bedrock_server
  elif [ -f "PocketMine-MP.phar" ]; then
    echo -e "${YELLOW}Starting PocketMine...${NC}"
    php PocketMine-MP.phar
  else
    echo -e "${RED}No server files found!${NC}"
    sleep 2
  fi
}

# Main menu
while true; do
  clear
  echo -e "${BLUE}=== Minecraft Server Manager ==="
  echo -e "Running in WISP/Pterodactyl${NC}"
  echo "1) Install Java Edition"
  echo "2) Install Bedrock Edition"
  echo "3) Start Server"
  echo "4) Server Console"
  echo "5) Exit"
  read -p "Choose option: " choice

  case $choice in
    1) install_java;;
    2) install_bedrock;;
    3) start_server;;
    4)
      echo -e "${YELLOW}Attaching to server console...${NC}"
      echo -e "${RED}Press Ctrl+P then Ctrl+Q to detach${NC}"
      sleep 2
      clear
      /bin/bash
      ;;
    5) exit 0;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1;;
  esac
done
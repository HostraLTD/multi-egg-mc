#!/bin/bash
# Complete Interactive Menu for WISP
clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    echo -e "${BLUE}=== Minecraft Server Manager ==="
    echo -e "Running in WISP/Pterodactyl${NC}"
    echo "1) Install Java Edition"
    echo "2) Install Bedrock Edition"
    echo "3) Start Server"
    echo "4) Server Console"
    echo "5) Exit"
    read -p "Choose option: " choice

    case $choice in
        1)
            clear
            echo -e "${BLUE}=== Java Edition ==="
            echo "1) Paper (Recommended)"
            echo "2) Vanilla"
            echo "3) Purpur"
            echo "4) Spigot"
            read -p "Choose software: " java_type
            
            echo -e "${YELLOW}Fetching versions...${NC}"
            versions=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[]' | tail -n 10)
            echo -e "\n${GREEN}Available versions:${NC}"
            echo "$versions"
            read -p "Enter version (e.g., 1.20.1): " version

            echo -e "${YELLOW}Downloading server...${NC}"
            cd /mnt/server
            rm -rf *
            
            case $java_type in
                1)
                    build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$version" | jq -r '.builds[-1]')
                    wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$version/builds/$build/downloads/paper-$version-$build.jar"
                    ;;
                2)
                    url=$(curl -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r ".versions[] | select(.id == \"$version\") | .url")
                    wget -O server.jar "$(curl -s "$url" | jq -r '.downloads.server.url')"
                    ;;
                3)
                    build=$(curl -s "https://api.purpurmc.org/v2/purpur/$version" | jq -r '.builds.latest')
                    wget -O server.jar "https://api.purpurmc.org/v2/purpur/$version/$build/download"
                    ;;
                4)
                    wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
                    java -jar BuildTools.jar --rev "$version" > /dev/null
                    mv spigot-*.jar server.jar
                    rm BuildTools.jar
                    ;;
            esac
            
            echo -e "${GREEN}Java server installed!${NC}"
            sleep 2
            ;;
            
        2)
            clear
            echo -e "${BLUE}=== Bedrock Edition ==="
            echo "1) Vanilla (Official)"
            echo "2) PocketMine-MP"
            read -p "Choose software: " bedrock_type
            
            cd /mnt/server
            rm -rf *
            
            case $bedrock_type in
                1)
                    echo -e "${YELLOW}Downloading Bedrock server...${NC}"
                    wget -O bedrock.zip "$(curl -s https://www.minecraft.net/en-us/download/server/bedrock | grep -oP 'https://[^"]+bin-linux[^"]+')"
                    unzip bedrock.zip
                    rm bedrock.zip
                    ;;
                2)
                    echo -e "${YELLOW}Downloading PocketMine...${NC}"
                    apt-get install -y php
                    wget -O server.phar https://github.com/pmmp/PocketMine-MP/releases/latest/download/PocketMine-MP.phar
                    ;;
            esac
            
            echo -e "${GREEN}Bedrock server installed!${NC}"
            sleep 2
            ;;
            
        3)
            cd /mnt/server
            if [ -f "server.jar" ]; then
                echo -e "${YELLOW}Starting Java server...${NC}"
                java -Xms128M -Xmx$(free -m | awk '/Mem:/ {print int($2*0.85)}')M -jar server.jar nogui
            elif [ -f "bedrock_server" ]; then
                echo -e "${YELLOW}Starting Bedrock server...${NC}"
                LD_LIBRARY_PATH=. ./bedrock_server
            elif [ -f "server.phar" ]; then
                echo -e "${YELLOW}Starting PocketMine...${NC}"
                php server.phar --no-wizard --disable-ansi
            else
                echo -e "${RED}No server files found!${NC}"
                sleep 2
            fi
            ;;
            
        4)
            echo -e "${YELLOW}Entering server console...${NC}"
            echo -e "${RED}Press Ctrl+D to return to menu${NC}"
            sleep 2
            /bin/bash
            ;;
            
        5)
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done

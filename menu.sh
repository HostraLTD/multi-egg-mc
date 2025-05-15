#!/bin/bash
# Complete Interactive Menu

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_java() {
    clear
    echo -e "${YELLOW}=== Java Edition Installation ==="
    echo "1) PaperMC (Recommended)"
    echo "2) Vanilla"
    echo "3) Purpur"
    read -p "Choose: " choice
    
    versions=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[]' | tail -n 5)
    echo -e "\n${GREEN}Available versions:${NC}\n$versions"
    read -p "Version: " version
    
    echo -e "${YELLOW}Downloading..."
    case $choice in
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
    esac
    
    echo "eula=true" > eula.txt
    echo -e "${GREEN}Installation complete!${NC}"
    sleep 2
}

# Main menu
while true; do
    clear
    echo -e "${GREEN}=== Minecraft Server Manager ==="
    echo "1) Install Java Edition"
    echo "2) Install Bedrock Edition"
    echo "3) Start Server"
    echo "4) Exit"
    read -p "Choose: " option

    case $option in
        1) install_java ;;
        2) install_bedrock ;;
        3) exec /mnt/server/start.sh ;;
        4) exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done

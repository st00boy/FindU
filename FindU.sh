#!/bin/bash

# Color Variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color (reset)

clear

# Function to animate line-by-line
animate_lines() {
    for line in "$@"; do
        echo -e "\t\t$line"
        sleep 0.07
    done
}

# Function to animate text char-by-char
animate_text() {
    local text="$1"
    printf "\t\t"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep 0.03
    done
    printf "\n"
}

# Boxed Retro-style Banner
banner_box="
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   ███████╗██╗███╗   ██╗██████╗ ██╗   ██╗                                     │
│   ██╔════╝██║████╗  ██║██╔══██╗██║   ██║                                     │
│   █████╗  ██║██╔██╗ ██║██║  ██║██║   ██║                                     │
│   ██╔══╝  ██║██║╚██╗██║██║  ██║██║   ██║                                     │
│   ██║     ██║██║ ╚████║██████╔╝╚██████╔╝                                     │
│   ╚═╝     ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝                                      │
│                                                                              │
│     DNS, WHOIS, Subdomains, GeoIP, Nmap & More                               │
│     Author: st00boy | https://github.com/st00boy                             │
└──────────────────────────────────────────────────────────────────────────────┘"

echo -e "\n\t\t$CYAN"
echo "$banner_box" | sed 's/^/\t\t/'
echo -e "$NC"

# Ask user for the domain name
echo -e "\n\t\t${GREEN}Enter the domain name: ${NC}"
echo -ne "\t\t"
read -r domain

# DNS Lookup
ip_addresses=$(dig +short "$domain")
if [ -z "$ip_addresses" ]; then
    ip_addresses=$(nslookup "$domain" | grep -oP '(?<=Address: )\S+')
fi

if [ -z "$ip_addresses" ]; then
    echo -e "\t\t${RED}Could not find an IP address for the domain $domain${NC}"
    exit 1
else
    echo -e "\t\t${YELLOW}The IP addresses for $domain are:${NC}"
    echo "$ip_addresses" | sed 's/^/\t\t/'
    if [ "$(echo "$ip_addresses" | wc -l)" -gt 1 ]; then
        echo -e "\t\t${CYAN}Select an IP address to scan:${NC}"
        select ip_to_scan in $ip_addresses; do
            if [ -n "$ip_to_scan" ]; then
                echo -e "\t\t${GREEN}You selected $ip_to_scan${NC}"
                break
            else
                echo -e "\t\t${RED}Invalid selection, please choose a valid number.${NC}"
            fi
        done
    else
        ip_to_scan=$ip_addresses
        echo -e "\t\t${GREEN}Only one IP address found: $ip_to_scan${NC}"
    fi
fi

# GeoIP Lookup
echo -e "\n\t\t${CYAN}Running GeoIP lookup for $ip_to_scan...${NC}"
sleep 1
geo_info=$(curl -s ipinfo.io/"$ip_to_scan")
echo -e "\t\t${YELLOW}"
echo "$geo_info" | jq -r '"IP: \(.ip)\nCity: \(.city)\nRegion: \(.region)\nCountry: \(.country)\nOrg: \(.org)"' | sed 's/^/\t\t/'
echo -e "${NC}"

# WHOIS Lookup
echo -e "\n\t\t${CYAN}Running whois lookup for $domain...${NC}"
sleep 1
whois "$domain" | head -n 20 | sed 's/^/\t\t/'

# Subdomain Enumeration using crt.sh
echo -e "\n\t\t${CYAN}Enumerating subdomains for $domain...${NC}"
sleep 1
subdomains=$(curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u)
if [ -n "$subdomains" ]; then
    echo -e "\t\t${YELLOW}Found subdomains:${NC}"
    echo "$subdomains" | sed 's/^/\t\t/'
else
    echo -e "\t\t${RED}No subdomains found or crt.sh is unreachable.${NC}"
fi

# Ask for Nmap scan
echo -e "\n\t\t${YELLOW}Do you want to scan the selected IP address? (y/n): ${NC}"
echo -ne "\t\t"
read -r scan_choice

if [[ "$scan_choice" =~ ^[Yy]$ ]]; then
    echo -e "\t\t${CYAN}Choose the type of nmap scan:${NC}"
    animate_lines \
        "${GREEN}1. Quick scan (default ports)${NC}" \
        "${GREEN}2. Full scan (all ports)${NC}" \
        "${GREEN}3. OS and version detection${NC}" \
        "${GREEN}4. Service version detection${NC}" \
        "${GREEN}5. Custom port scan (e.g., 22,80,443)${NC}" \
        "${GREEN}6. Run ALL scans${NC}"

    echo -e "\t\t${CYAN}Enter your choice (1-6): ${NC}"
    echo -ne "\t\t"
    read -r scan_type
    scan_result=""

    case "$scan_type" in
        1)
            animate_text "Running quick scan on $ip_to_scan..."
            scan_result=$(nmap "$ip_to_scan")
            ;;
        2)
            animate_text "Running full scan on $ip_to_scan..."
            scan_result=$(nmap -p- "$ip_to_scan")
            ;;
        3)
            animate_text "Running OS and version detection on $ip_to_scan..."
            scan_result=$(nmap -O "$ip_to_scan")
            ;;
        4)
            animate_text "Running service version detection on $ip_to_scan..."
            scan_result=$(nmap -sV "$ip_to_scan")
            ;;
        5)
            echo -e "\t\t${CYAN}Enter the ports to scan (e.g., 22,80,443): ${NC}"
            echo -ne "\t\t"
            read -r ports
            animate_text "Running custom port scan on $ip_to_scan..."
            scan_result=$(nmap -p "$ports" "$ip_to_scan")
            ;;
        6)
            animate_text "Running ALL scans on $ip_to_scan..."
            scan_result+=$'--- QUICK SCAN ---\n'
            scan_result+=$(nmap "$ip_to_scan")
            scan_result+=$'\n\n--- FULL PORT SCAN ---\n'
            scan_result+=$(nmap -p- "$ip_to_scan")
            scan_result+=$'\n\n--- OS & VERSION DETECTION ---\n'
            scan_result+=$(nmap -O "$ip_to_scan")
            scan_result+=$'\n\n--- SERVICE VERSION DETECTION ---\n'
            scan_result+=$(nmap -sV "$ip_to_scan")
            ;;
        *)
            echo -e "\t\t${RED}Invalid choice. No scan performed.${NC}"
            ;;
    esac

    if [ -n "$scan_result" ]; then
        echo -e "\n\t\t${YELLOW}Scan completed. Displaying results...\n${NC}"
        echo "$scan_result" | sed 's/^/\t\t/'

        echo -e "\n\t\t${CYAN}Do you want to save the results to a text file in the current directory? (y/n): ${NC}"
        echo -ne "\t\t"
        read -r save_choice
        if [[ "$save_choice" =~ ^[Yy]$ ]]; then
            safe_domain=$(echo "$domain" | tr -cd '[:alnum:]_')
            filename="$(pwd)/findus_scan_${safe_domain}_$(date +%Y%m%d_%H%M%S).txt"
            echo "$scan_result" > "$filename"
            echo -e "\t\t${GREEN}Results saved to $filename${NC}"
        fi
    fi
else
    echo -e "\t\t${YELLOW}No scan performed.${NC}"
fi

# Appreciation Message
echo -e "\n\t\t${CYAN}"
animate_text "🎉 Thank you for using FindU!"
animate_text "Stay curious and keep exploring 🌐"
animate_text "Created with ❤️ by st00boy"
echo -e "${NC}"


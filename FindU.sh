#!/bin/bash

# Color Variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color (reset)

# Required Tools Check
required_cmds=("dig" "curl" "jq" "nmap" "whois")
for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "\t\t${RED}Error: $cmd is not installed. Please install it and try again.${NC}"
        exit 1
    fi
done

# Text Animations
animate_text() {
    local text="$1"
    printf "\t\t"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep 0.03
    done
    printf "\n"
}

animate_lines() {
    for line in "$@"; do
        echo -e "\t\t$line"
        sleep 0.07
    done
}

# Center Output
center_text() {
    local text="$1"
    local width
    width=$(tput cols)
    while IFS= read -r line; do
        local padding=$(( (width - ${#line}) / 2 ))
        printf "%*s%s\n" "$padding" "" "$line"
    done <<< "$text"
}

# About/Info
show_info() {
    clear
    echo -e "${CYAN}"
    center_text "FindU - Domain Reconnaissance Toolkit"
    center_text "Author: st00boy"
    center_text "https://github.com/st00boy"
    echo -e "${NC}\n"
    center_text "A terminal-based reconnaissance tool that performs DNS, WHOIS,"
    center_text "GeoIP lookups, Subdomain discovery, and Nmap scanning."
    echo -e "\n${CYAN}Press Enter to return to the main menu...${NC}"
    read -r
}

# Main Menu
main_menu() {
    while true; do
        clear
        echo -e "\n${YELLOW}"
        center_text "==== FindU Recon Tool ===="
        echo -e "${NC}"
        animate_lines \
            "${GREEN}1. Start Domain Scan${NC}" \
            "${GREEN}2. About / Help${NC}" \
            "${GREEN}3. Exit${NC}"
        echo -ne "\n\t\t${CYAN}Enter your choice (1-3): ${NC}"
        read -r menu_choice

        case $menu_choice in
            1) run_scan ;;
            2) show_info ;;
            3)
                animate_text "👋 Goodbye!"
                exit 0
                ;;
            *) echo -e "\t\t${RED}Invalid option, try again.${NC}"; sleep 1 ;;
        esac
    done
}

# Scanning Function
run_scan() {
    clear
    echo -e "\n\t\t${GREEN}Enter the domain name: ${NC}"
    echo -ne "\t\t"
    read -r domain

    ip_addresses=$(dig +short "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    if [ -z "$ip_addresses" ]; then
        ip_addresses=$(nslookup "$domain" | awk '/^Address: / { print $2 }' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
    fi

    if [ -z "$ip_addresses" ]; then
        echo -e "\t\t${RED}Could not find an IP address for the domain $domain${NC}"
        return
    fi

    echo -e "\t\t${YELLOW}IP addresses for $domain:${NC}"
    center_text "$ip_addresses"
    full_output="\n[+] IP addresses for $domain:\n$ip_addresses\n"

    if [ "$(echo "$ip_addresses" | wc -l)" -gt 1 ]; then
        echo -e "\t\t${CYAN}Select an IP address to scan:${NC}"
        select ip_to_scan in $ip_addresses; do
            if [ -n "$ip_to_scan" ]; then
                echo -e "\t\t${GREEN}You selected $ip_to_scan${NC}"
                break
            else
                echo -e "\t\t${RED}Invalid selection, try again.${NC}"
            fi
        done
    else
        ip_to_scan=$ip_addresses
        echo -e "\t\t${GREEN}Only one IP address found: $ip_to_scan${NC}"
    fi

    # GeoIP Lookup
    echo -e "\n\t\t${CYAN}GeoIP Lookup for $ip_to_scan...${NC}"
    geo_info=$(curl -s ipinfo.io/"$ip_to_scan")
    geo_output=$(echo "$geo_info" | jq -r '"IP: \(.ip)\nCity: \(.city)\nRegion: \(.region)\nCountry: \(.country)\nOrg: \(.org)"')
    center_text "$geo_output"
    full_output+="\n[+] GeoIP Info:\n$geo_output\n"

    # WHOIS Lookup
    echo -e "\n\t\t${CYAN}WHOIS Lookup for $domain...${NC}"
    whois_output=$(whois "$domain" | head -n 20)
    center_text "$whois_output"
    full_output+="\n[+] WHOIS Info:\n$whois_output\n"

    # Subdomain Enumeration
    echo -e "\n\t\t${CYAN}Enumerating Subdomains...${NC}"
    subdomains=$(curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u)
    if [ -n "$subdomains" ]; then
        center_text "$subdomains"
        full_output+="\n[+] Subdomains:\n$subdomains\n"
    else
        echo -e "\t\t${RED}No subdomains found or crt.sh unreachable.${NC}"
    fi

    # Nmap Scan
    echo -e "\n\t\t${CYAN}Choose Nmap scan type:${NC}"
    animate_lines \
        "${GREEN}1. Quick scan${NC}" \
        "${GREEN}2. Full scan${NC}" \
        "${GREEN}3. OS and version detection${NC}" \
        "${GREEN}4. Service version detection${NC}" \
        "${GREEN}5. Custom port scan${NC}" \
        "${GREEN}6. Run ALL scans${NC}"

    echo -ne "\t\t${CYAN}Enter your choice: ${NC}"
    read -r scan_type
    scan_result=""

    case "$scan_type" in
        1) scan_result=$(nmap "$ip_to_scan") ;;
        2) scan_result=$(nmap -p- "$ip_to_scan") ;;
        3) scan_result=$(nmap -O "$ip_to_scan") ;;
        4) scan_result=$(nmap -sV "$ip_to_scan") ;;
        5)
            echo -ne "\t\t${CYAN}Enter ports (e.g. 22,80): ${NC}"
            read -r ports
            scan_result=$(nmap -p "$ports" "$ip_to_scan")
            ;;
        6)
            scan_result+=$'\n--- Quick Scan ---\n'
            scan_result+=$(nmap "$ip_to_scan")
            scan_result+=$'\n--- Full Port Scan ---\n'
            scan_result+=$(nmap -p- "$ip_to_scan")
            scan_result+=$'\n--- OS Detection ---\n'
            scan_result+=$(nmap -O "$ip_to_scan")
            scan_result+=$'\n--- Service Version Detection ---\n'
            scan_result+=$(nmap -sV "$ip_to_scan")
            ;;
        *) echo -e "\t\t${RED}Invalid scan type.${NC}" ;;
    esac

    center_text "$scan_result"
    full_output+="\n[+] Nmap Results:\n$scan_result\n"

    # Auto Save
    safe_domain=$(echo "$domain" | tr -cd '[:alnum:]_')
    filename="findU_scan_${safe_domain}_$(date +%Y%m%d_%H%M%S).txt"
    echo -e "$full_output" > "$filename"
    echo -e "\t\t${GREEN}Results saved to $filename${NC}"

    echo -e "\n\t\t${CYAN}"
    animate_text "🎉 Thank you for using FindU!"
    animate_text "Stay curious and keep exploring 🌐"
    echo -e "${NC}"
    echo -e "\n\t\t${CYAN}Returning to main menu...${NC}"
    sleep 2
}

# Start the Tool
main_menu

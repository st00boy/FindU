#!/bin/bash

# Color Variables
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color (reset)

# Check for required tools
required_cmds=("dig" "curl" "jq" "nmap" "whois")
for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "\t\t${RED}Error: $cmd is not installed. Please install it and try again.${NC}"
        exit 1
    fi
done

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

# Function to animate line-by-line
animate_lines() {
    for line in "$@"; do
        echo -e "\t\t$line"
        sleep 0.07
    done
}

# Banner
show_banner() {
    clear
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
    echo -e "$CYAN"
    echo "$banner_box" | sed 's/^/\t\t/'
    echo -e "$NC"
}

# Main Menu
main_menu() {
    while true; do
        show_banner
        echo -e "\n\t\t${YELLOW}Select an option:${NC}"
        animate_lines \
            "${GREEN}1. Start Domain Scan${NC}" \
            "${GREEN}2. About / Help${NC}" \
            "${GREEN}3. Exit${NC}"
        echo -ne "\n\t\t${CYAN}Enter your choice (1-3): ${NC}"
        read -r menu_choice

        case $menu_choice in
            1) run_scan ;;
            2) show_help ;;
            3)
                animate_text "👋 Goodbye!"
                exit 0
                ;;
            *) echo -e "\t\t${RED}Invalid option, try again.${NC}"; sleep 1 ;;
        esac
    done
}

# Help/About section
show_help() {
    clear
    show_banner
    echo -e "\n\t\t${YELLOW}About FindU${NC}"
    echo -e "\t\tA powerful terminal tool to gather domain information using:"
    animate_lines \
        "- DNS & IP lookup (dig, nslookup)" \
        "- WHOIS records" \
        "- GeoIP using ipinfo.io" \
        "- Subdomain enumeration via crt.sh" \
        "- Nmap scans (Quick, Full, OS detection, Custom)" \
        "- Result saving to a .txt file"
    echo -e "\n\t\t${CYAN}Press Enter to return to the main menu...${NC}"
    read
}

# The full scanning logic goes here (same as before)
run_scan() {
    clear
    show_banner

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

    echo -e "\t\t${YELLOW}The IP addresses for $domain are:${NC}"
    echo "$ip_addresses" | sed 's/^/\t\t/'
    full_output="\n[+] IP addresses for $domain:\n$ip_addresses\n"

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

    # GeoIP
    echo -e "\n\t\t${CYAN}Running GeoIP lookup for $ip_to_scan...${NC}"
    geo_info=$(curl -s ipinfo.io/"$ip_to_scan")
    geo_output=$(echo "$geo_info" | jq -r '"IP: \(.ip)\nCity: \(.city)\nRegion: \(.region)\nCountry: \(.country)\nOrg: \(.org)"')
    echo "$geo_output" | sed 's/^/\t\t/'
    full_output+="\n[+] GeoIP Info:\n$geo_output\n"

    # WHOIS
    echo -e "\n\t\t${CYAN}Running WHOIS lookup for $domain...${NC}"
    whois_output=$(whois "$domain" | head -n 20)
    echo "$whois_output" | sed 's/^/\t\t/'
    full_output+="\n[+] WHOIS Info:\n$whois_output\n"

    # Subdomains
    echo -e "\n\t\t${CYAN}Enumerating subdomains...${NC}"
    subdomains=$(curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u)
    if [ -n "$subdomains" ]; then
        echo "$subdomains" | sed 's/^/\t\t/'
        full_output+="\n[+] Subdomains:\n$subdomains\n"
    else
        echo -e "\t\t${RED}No subdomains found or crt.sh unreachable.${NC}"
    fi

    # Nmap
    echo -e "\n\t\t${YELLOW}Do you want to scan the IP with Nmap? (y/n): ${NC}"
    echo -ne "\t\t"
    read -r scan_choice

    if [[ "$scan_choice" =~ ^[Yy]$ ]]; then
        echo -e "\t\t${CYAN}Choose Nmap scan type:${NC}"
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

        echo "$scan_result" | sed 's/^/\t\t/'
        full_output+="\n[+] Nmap Results:\n$scan_result\n"
    fi

    # Save output
    echo -e "\n\t\t${CYAN}Save all results to a file? (y/n): ${NC}"
    echo -ne "\t\t"
    read -r save_choice
    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        safe_domain=$(echo "$domain" | tr -cd '[:alnum:]_')
        filename="findU_scan_${safe_domain}_$(date +%Y%m%d_%H%M%S).txt"
        echo -e "$full_output" > "$filename"
        echo -e "\t\t${GREEN}Results saved to $filename${NC}"
    fi

    echo -e "\n\t\t${CYAN}"
    animate_text "🎉 Thank you for using FindU!"
    animate_text "Stay curious and keep exploring 🌐"
    echo -e "${NC}"
    echo -e "\n\t\t${CYAN}Returning to main menu...${NC}"
    sleep 2
}

# Start the tool
main_menu

# 🔍 FindU: Domain Recon Tool

**FindU** is a retro-styled, terminal-based reconnaissance tool designed for gathering essential information about a domain. It combines DNS, GeoIP, WHOIS, subdomain enumeration, and Nmap scanning into a single slick Bash script. With colorful animations and a user-friendly menu, it's perfect for beginners and pros alike.

---

## 🚀 Features

- ✅ DNS Lookup & IP Resolution
- 🌐 GeoIP Lookup via `ipinfo.io`
- 🕵️ WHOIS Information
- 📡 Subdomain Enumeration (using `crt.sh`)
- 🔎 Multiple Nmap Scan Modes:
  - Quick Scan
  - Full Port Scan
  - OS Detection
  - Service Version Detection
  - Custom Port Scanning
  - Run All Scans at Once
- 💾 Save all results to a timestamped `.txt` file
- 🎨 Retro terminal aesthetics and smooth animations
- 📜 Interactive main menu + Help section

---

## 📥 Installation

> **Requirements:**
> Ensure the following tools are installed on your system:
>
> `dig`, `nslookup`, `curl`, `jq`, `nmap`, `whois`

Install them using:

```bash
# Debian/Ubuntu
sudo apt install dnsutils curl jq nmap whois

# RedHat/CentOS
sudo yum install bind-utils curl jq nmap whois

# MacOS (using Homebrew)
brew install bind curl jq nmap whois

🧪 Usage
 1. Clone or download the script:
  git clone https://github.com/st00boy/findU.git
  cd findU
  chmod +x findU.sh
  ./findU.sh

 2. Follow the menu to:

    Start scanning a domain

    View Help/About info

    Exit gracefully

📂 Output Example
When the scan completes, you'll have the option to save the results:
findU_scan_example_com_20250408_194512.txt

This includes:
     IP addresses
     GeoIP details
     WHOIS info
     Subdomains
     Nmap results (if selected)

🧠 About the Author
st00boy
💻 GitHub: github.com/st00boy
❤️ Crafted with curiosity and creativity for learners, hackers, and tinkerers.


🛡️ Disclaimer
This tool is intended for educational and authorized testing purposes only. You can always obtain permission before scanning any domain you don't own.


⭐️ Support & Contributions
If you like this tool, consider ⭐️ starring the repo or contributing! Pull requests, bug reports, or feature ideas are welcome.





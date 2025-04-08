# 🛰️ FindUs - All-in-One Network Recon Tool

**FindUs** is a sleek, terminal-based Bash tool designed for quick and efficient reconnaissance of domains and IP addresses. It wraps essential utilities like `dig`, `whois`, `nmap`, `crt.sh`, and `ipinfo.io` in a retro-styled interface, with animations and a centered layout for that smooth hacker aesthetic 😎.

---

## ✨ Features

- 🔍 **DNS Lookup** (with fallback to `nslookup`)
- 🌐 **WHOIS Lookup**
- 🛰️ **GeoIP Information** via [ipinfo.io](https://ipinfo.io)
- 🧠 **Subdomain Enumeration** using [crt.sh](https://crt.sh)
- 🛠️ **Nmap Scan Options:**
  - Quick scan
  - Full port scan
  - OS & version detection
  - Service version detection
  - Custom port scan (e.g., 22,80,443)
  - All scans combined
- 💾 **Save Scan Results** to a `.txt` file in the current working directory
- 🎛️ Clean UI with **animated effects** and **centered prompts**

---

## 🧰 Requirements

Ensure the following tools are installed on your system:

- `bash`
- `curl`
- `jq`
- `nmap`
- `dig` or `nslookup`
- `whois`

You can install missing tools via your package manager:
```bash
# Example for Debian/Ubuntu:
sudo apt update && sudo apt install curl jq nmap dnsutils whois

🚀 Usage
 git clone https://github.com/st00boy/findus
cd findus
chmod +x findus.sh
./findus.sh

💾 Saving Results
After completing a scan, you'll be prompted to save the results. If you choose to save:

📁 A file like: findus_scan_exampledomain_com_20250408_123456.txt
will be saved in your current working directory.

👨‍💻 Author
Made with ❤️ by st00boy

📜 License
This project is open-source and free to use under the MIT License.

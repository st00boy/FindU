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

## 🖥️ Operating System Compatibility

The FindUs script is designed to work on:

- ✅ **Linux** (Debian, Ubuntu, Arch, Kali, etc.)
- ✅ **macOS** (with Homebrew-installed dependencies)
- ⚠️ **Windows** (only via WSL - Windows Subsystem for Linux)

> ❗ Native Windows environments (e.g., Command Prompt or PowerShell) are not supported due to dependency on Unix-based tools like `bash`, `jq`, and `nmap`.

Make sure you're running this script in a Bash-compatible shell on a supported OS.


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

⚠️ Disclaimer
This tool is intended solely for educational and ethical research purposes.
You must only use FindUs on systems and networks you own or have explicit permission to test.
Unauthorized scanning or probing of third-party systems without consent is illegal and unethical.

📜 License
This project is open-source and free to use under the MIT License.

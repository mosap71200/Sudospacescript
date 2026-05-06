#!/bin/bash

# --- إعدادات المسارات ---
USER_HOME=$HOME
UDOCKER_BIN="$USER_HOME/.local/bin/udocker/udocker"

# --- واجهة SudoSpace الاحترافية الكبيرة ---
# وضعناها في متغير ليسهل استدعاؤها في أي مكان
BANNER_ART='
    ____             __       _____                           
   / __/_  ______   / /____  / ___/____  ____ _________       
   \__ \/ / / / __  / / __ \ \__ \/ __ \/ __ \/ ___/ _ \      
  ___/ / /_/ / /_/ / / /_/ /___/ / /_/ / /_/ / /__/  __/      
 /____/\__,_/\__,_/_/\____//____/ .___/\__,_/\___/\___/       
                               /_/                            '

show_banner() {
    clear
    echo -e "\e[1;32m================================================================\e[0m"
    echo -e "\e[1;32m$BANNER_ART\e[0m"
    echo -e "\e[1;32m================================================================\e[0m"
    echo -e "   \e[1;36mDeveloped by: \e[1;33mmosap \e[1;36m| Channel: \e[1;33mSudoSpace\e[0m"
    echo -e "\e[1;32m================================================================\e[0m"
    echo ""
}

# --- تثبيت udocker إذا لم يكن موجوداً ---
if [ ! -f "$UDOCKER_BIN" ]; then
    show_banner
    echo -e "\e[1;33m[*] First time setup... Installing udocker for SudoSpace...\e[0m"
    mkdir -p ~/.local/bin
    curl -L https://github.com/indigo-dc/udocker/releases/download/1.3.17/udocker-1.3.17.tar.gz | tar -xz -C ~/.local/bin --strip-components=1
    chmod +x "$UDOCKER_BIN"
    "$UDOCKER_BIN" install
fi

show_banner

# --- اختيار النظام ---
echo -e "\e[1;36mChoose your OS to install:\e[0m"
echo "1) Kali Linux (Recommended)"
echo "2) Ubuntu"
echo "3) Debian"
read -p "Select [1-3]: " os_choice

case $os_choice in
    1) OS_IMG="kalilinux/kali-rolling"; OS_NAME="kali_space" ;;
    2) OS_IMG="ubuntu"; OS_NAME="ubuntu_space" ;;
    3) OS_IMG="debian"; OS_NAME="debian_space" ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

# --- تثبيت النظام ---
echo -e "\n\e[1;33m[+] Pulling $OS_IMG... Please wait.\e[0m"
"$UDOCKER_BIN" pull $OS_IMG
"$UDOCKER_BIN" create --name=$OS_NAME $OS_IMG

# --- إعدادات الإقلاع ---
echo -e "\n\e[1;36mHow do you want to start the OS?\e[0m"
echo "1) Auto-start (Instant access on SSH login)"
echo "2) Manual-start (Choose your own command)"
read -p "Select [1-2]: " boot_choice

# --- تجهيز سكريبت التشغيل الأساسي (بالواجهة الفخمة) ---
cat << EOF > ~/space.sh
#!/bin/bash
clear
echo -e "\e[1;32m================================================================\e[0m"
echo -e "\e[1;32m$BANNER_ART\e[0m"
echo -e "\e[1;32m================================================================\e[0m"
echo -e "   \e[1;36mWelcome to your system, \e[1;33mmosap\e[0m"
echo -e "\e[1;32m================================================================\e[0m"
export PATH=\$PATH:$USER_HOME/.local/bin/udocker
$UDOCKER_BIN run --user=root $OS_NAME /bin/bash
EOF
chmod +x ~/space.sh

if [ "$boot_choice" == "1" ]; then
    # تنظيف أي إقلاع قديم
    sed -i '/space.sh/d' ~/.bash_profile
    echo "~/space.sh" >> ~/.bash_profile
    echo -e "\e[1;32m[+] Auto-start enabled!\e[0m"
else
    # إقلاع يدوي بكلمة مخصصة
    echo -e "\e[1;33m"
    read -p "Enter the command name you want to use (e.g., 'kali' or 'sudo'): " custom_cmd
    echo -e "\e[0m"
    sed -i "/alias $custom_cmd=/d" ~/.bashrc
    echo "alias $custom_cmd='~/space.sh'" >> ~/.bashrc
    echo -e "\e[1;32m[+] Done! Type '\e[1;33m$custom_cmd\e[1;32m' to enter SudoSpace.\e[0m"
fi

show_banner
echo -e "\e[1;32m[SUCCESS] SudoSpace System is Ready, Happy Hacking!\e[0m"
source ~/.bashrc 2>/dev/null

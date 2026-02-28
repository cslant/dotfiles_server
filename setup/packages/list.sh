#!/bin/bash

REQUIRED_PKG="git"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
echo "Checking for $REQUIRED_PKG: $PKG_OK"
if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    sudo apt-get install -y $REQUIRED_PKG
fi

echo "=========================== zsh ==========================="
while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        yn="y"
    else
        read -r -p "Do you want to install zsh and oh-my-zsh? (Y/N)  " yn
    fi
    case $yn in
    [Yy]*)
        bash zsh.sh
        break
        ;;
    [Nn]*) break ;;
    *) echo "Please answer yes or no." ;;
    esac
done


installPackages() {
    PACKAGE_LIST=("curl" "wget" "make" "vim" "tmux" "nano" "npm" "certbot" "python3-certbot-nginx" "fail2ban" "htop" "btop")

    for packageName in "${PACKAGE_LIST[@]}"; do
        echo "=========================== $packageName ==========================="

        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' "$packageName" | grep "install ok installed")
        echo "Checking for $packageName: $PKG_OK"
        while true; do
            if [[ -n $PKG_OK ]]; then
                echo "$packageName is already installed."
                echo ""
                break
            fi
            if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
                yn="y"
            else
                read -r -p "Do you want to install $packageName? (Y/N)  " yn
            fi
            case $yn in
            [Yy]*)
                if [ "" = "$PKG_OK" ]; then
                    echo "No $packageName. Setting up $packageName."
                    sudo apt install -y "$packageName"
                fi
                echo ""
                break
                ;;
            [Nn]*) break ;;
            *) echo "Please answer yes or no." ;;
            esac
        done
    done
}
installPackages

echo "=========================== nvm ==========================="
while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        yn="y"
    else
        read -r -p "Do you want to install nvm? (Y/N)  " yn
    fi
    case $yn in
    [Yy]*)
        bash nvm.sh
        break
        ;;
    [Nn]*) break ;;
    *) echo "Please answer yes or no." ;;
    esac
done
echo ""

echo "====================== redis-server ======================="
while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        yn="y"
    else
        read -r -p "Do you want to install redis-server? (Y/N)  " yn
    fi
    case $yn in
    [Yy]*)
        bash redis.sh
        break
        ;;
    [Nn]*) break ;;
    *) echo "Please answer yes or no." ;;
    esac
done
echo ""

#!/bin/bash

THIS_DIR=$(pwd)

echo '####################################################################'
echo '####################################################################'
echo '######################### For Ubuntu Server ########################'
echo '####################################################################'
echo '####################################################################'
echo ''
echo "=========================== update ==========================="
# check root user right? if not, check group sudo, if have, run update and upgrade, if not, skip
if [ "$EUID" -eq 0 ]; then
    echo "Running as root user. Proceeding with update and upgrade."
    apt-get -y update
    apt-get -y upgrade
elif groups "$USER" | grep -q "\bsudo\b"; then
    echo "User $USER is in the sudo group. Proceeding with update and upgrade."
    sudo apt-get -y update
    sudo apt-get -y upgrade
else
    echo "User $USER is not in the sudo group. Skipping update and upgrade."
fi

echo '####################################################################'
echo '######################### Run package list #########################'
echo '####################################################################'
echo ''

cd "$THIS_DIR"/setup/packages || exit
bash list.sh
cd "$THIS_DIR" || exit

echo '####################################################################'
while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        yn="y"
    else
        read -r -p "Do you want to install some packages, programs for Developer? (Y/N)  " yn
    fi
    case $yn in
    [Yy]*)
        cd "$THIS_DIR"/setup/develop || exit
        bash setup.sh
        cd "$THIS_DIR" || exit
        break
        ;;
    [Nn]*) break ;;
    *) echo "Please answer yes or no." ;;
    esac
done

# CHeck and skip system if have not group sudo
if groups "$USER" | grep -q "\bsudo\b"; then
     echo "User $USER is in the sudo group. Proceeding with system setup."
     echo '####################################################################'
     echo '############################# System ###############################'
     echo '####################################################################'
     echo ''
     cd "$THIS_DIR"/setup/system || exit
     bash setup.sh
     bash change-port.sh
else
     echo "User $USER is not in the sudo group. Skipping system setup."
fi

echo ''
echo '####################################################################'
echo '########################### after setup ############################'
echo '####################################################################'
echo ''
cd "$THIS_DIR"/setup/options || exit
bash after-setup.sh

echo "####################################################################"
echo "######################### install docker ###########################"
while true; do
    if groups "$USER" | grep -q "\bsudo\b"; then
        echo "User $USER is in the sudo group. Proceeding with docker installation."
    else
        echo "User $USER is not in the sudo group. Skipping docker installation."
        break
    fi

    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        yn="y"
    else
        read -r -p "Do you want to install docker? (Y/N)  " yn
    fi
    case $yn in
    [Yy]*)
        cd "$THIS_DIR"/setup/develop/ || exit
        bash docker.sh
        cd "$THIS_DIR" || exit
        break
        ;;
    [Nn]*) break ;;
    *) echo "Please answer yes or no." ;;
    esac
done

echo ''
echo "####################################################################"
echo "####################### install Zabbix #############################"
echo "####################################################################"
echo ''
while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
        zabbix_choice="server"
    else
        read -r -p "Do you want to install Zabbix? (server/client/no)  " zabbix_choice
    fi
    case $zabbix_choice in
    [Ss][Ee][Rr][Vv][Ee][Rr]|server)
        cd "$THIS_DIR"/setup/system/ || exit
        sudo bash zabbix.sh server
        cd "$THIS_DIR" || exit
        break
        ;;
    [Cc][Ll][Ii][Ee][Nn][Tt]|client)
        cd "$THIS_DIR"/setup/system/ || exit
        sudo bash zabbix.sh client
        cd "$THIS_DIR" || exit
        break
        ;;
    [Nn][Oo]|no|n) break ;;
    *) echo "Please answer server, client, or no." ;;
    esac
done


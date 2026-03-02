#!/bin/bash

REQUIRED_PKG="zsh"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
echo "Checking for $REQUIRED_PKG: $PKG_OK"

# Check if the package is installed. If not, install it (install if have FORCE_ZSH env = true)
if [ "" = "$PKG_OK" ] || [ "true" = "$FORCE_ZSH" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    sudo apt-get install -y $REQUIRED_PKG

    # start ====== oh-my-zsh
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    # Fast Syntax Highlighting
    git clone https://github.com/zdharma/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/fast-syntax-highlighting
    # ZSH Autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    # p10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
    # end ====== oh-my-zsh

    # set zsh as default
    chsh -s /bin/$REQUIRED_PKG
fi

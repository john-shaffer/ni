#!/usr/bin/env bash
echo
echo Bootstrapping the NI installer, hold on...
echo
nix-env -iA nixos.diceware nixos.wget 
wget -q https://raw.githubusercontent.com/john-shaffer/ni/master/install.sh -O /etc/nixos/install.sh && chmod +x /etc/nixos/install.sh
bash /etc/nixos/install.sh

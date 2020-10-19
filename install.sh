#!/bin/bash

# install script for locally testing new versions

echo "installing instantTHEMES"
if ! [ -e ./instantthemes ]; then
    echo "run from instantthemes git repo please"
    exit 1
fi

chinstall() {
    cat "$1" | sudo tee "$2"
    sudo chmod +x "$2"
}
chmove() {
    sudo cp -r ./"$1" /usr/share/instantthemes/"$1"
}

sudo rm -rf /usr/share/instantthemes
sudo mkdir -p /usr/share/instantthemes

chinstall instantthemes /usr/bin/instantthemes
sudo mkdir -p /usr/share/instantthemes/

chmove dunst
chmove configs
chmove colors
chmove scripts
chmove xresources

#!/bin/bash
cd

source <(curl -Ls https://git.io/JerLG)
pb git
pb config
pb gtk
pb instantos

instanttheme arc

gtktheme Arc

# gtk icons
if ! icons_exist Papirus &>/dev/null; then
    pushd .
    cd
    gitclone PapirusDevelopmentTeam/papirus-icon-theme
    cd papirus-icon-theme
    ./install.sh
    cd ..
    rm -rf papirus-icon-theme
    popd
fi

gtkicons Papirus
setcursor elementary

rofitheme arc
dunsttheme arc

curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/sourcecodepro.sh" | bash
curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/roboto.sh" | bash

curl -s "https://raw.githubusercontent.com/instantOS/instantTHEMES/master/xresources/arc" > ~/.Xresources

echo "done installing arc theme"

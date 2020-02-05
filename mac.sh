#!/bin/bash

##############################
## theme emulating mac look ##
##############################

themefetch() {
    echo "fetching mac theme"

    mkdir -p ~/.cache/mactheme
    cd ~/.cache/mactheme

    # gtk theme
    if ! themeexists Mojave-light &>/dev/null; then
        gitclone vinceliuice/Mojave-gtk-theme
        cd Mojave-gtk-theme
        ./install.sh
        cd ..
    fi

    # gtk icons
    if ! icons_exist McMojave-circle &>/dev/null; then
        gitclone vinceliuice/McMojave-circle
        cd McMojave-circle
        ./install.sh
        cd ..
    fi
    curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/sfpro.sh" | bash

}

themeapply() {

    gtkicons McMojave-circle

    papercursor osx
    setcursor osx
    gtktheme Mojave-light

    rofitheme mac
    dunsttheme mac
    gtkfont 'SF Pro Display 10'
}

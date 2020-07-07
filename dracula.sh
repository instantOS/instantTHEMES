#!/bin/bash

##################################
## materiacula and paper cursor ##
##################################

themefetch() {
    echo "fetching dracula theme"
    if ! themeexists materiacula &>/dev/null && icons_exist materiacula &>/dev/null; then
        gitclone materiacula
        cd materiacula
        bash install.sh
        cd ..
        rm -rf materiacula
    fi
    curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/monaco.sh" | bash
    curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/roboto.sh" | bash
    papercursor paper-instantos

}

themeapply() {

    gtktheme materiacula
    gtkicons materiacula
    gtkfont "Roboto 10"
    xtheme dracula

    setcursor paper-instantos

    rofitheme dracula
    dunsttheme dracula
}

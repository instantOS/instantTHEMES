#!/bin/bash

##################################
## materiacula and paper cursor ##
##################################

cd
source /usr/share/paperbash/import.sh

pb git
pb gtk
pb instantos

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

}

themeapply() {
    echo "applying dracula theme"

    instanttheme dracula

    gtktheme materiacula
    gtkicons materiacula
    gtkfont "Roboto 10"

    papercursor paper
    setcursor paper

    rofitheme dracula
    dunsttheme dracula
    xtheme dracula
}

if [ -n "$1" ]; then
    case "$1" in
    apply)
        themeapply
        ;;
    fetch)
        themefetch
        ;;
    *)
        themefetch
        themeapply
        ;;
    esac
fi

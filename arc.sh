#!/bin/bash

############################################################################
## widely supported combination of arc and papirus with elementary cursor ##
############################################################################

themefetch() {
    echo "fetching arc theme"
    # gtk icons
    if ! icons_exist Papirus &>/dev/null; then
        pushd .
        cd || exit 1
        gitclone PapirusDevelopmentTeam/papirus-icon-theme
        cd papirus-icon-theme || exit 1
        ./install.sh
        cd .. || exit 1
        rm -rf papirus-icon-theme
        popd || exit 1
    fi

    curl -s "https://raw.githubusercontent.com/instantos/dotfiles/master/fonts/sourcecodepro.sh" | bash
    curl -s "https://raw.githubusercontent.com/instantos/dotfiles/master/fonts/roboto.sh" | bash
    papercursor elementary-instantos

}

lighttheme() {
    gtktheme Arc
    gtkicons Papirus
}

darktheme() {
    gtktheme Arc-Dark
    gtkicons Papirus-Dark
}

themeapply() {

    lighttheme
    xtheme arc
    setcursor elementary-instantos

    rofitheme arc
    dunsttheme arc
}

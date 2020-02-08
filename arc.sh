#!/bin/bash

############################################################################
## widely supported combination of arc and papirus with elementary cursor ##
############################################################################

themefetch() {
    echo "fetching arc theme"
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

    curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/sourcecodepro.sh" | bash
    curl -s "https://raw.githubusercontent.com/paperbenni/dotfiles/master/fonts/roboto.sh" | bash
    papercursor elementary

}

themeapply() {

    gtktheme Arc
    gtkicons Papirus

    xtheme arc
    setcursor elementary

    rofitheme arc
    dunsttheme arc
}

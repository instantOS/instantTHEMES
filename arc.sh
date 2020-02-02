#!/bin/bash

############################################################################
## widely supported combination of arc and papirus with elementary cursor ##
############################################################################

cd
source /usr/share/paperbash/import.sh

pb git
pb config
pb gtk
pb instantos

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

}

themeapply() {
    echo "applying arc theme"
    instanttheme arc

    gtktheme Arc
    gtkicons Papirus

    papercursor elementary
    setcursor elementary

    rofitheme arc
    dunsttheme arc
    xtheme arc
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

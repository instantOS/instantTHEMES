#!/bin/bash

# theming app for instantOS
# Aims to configure as much applications as possible to conform to the theme

source /usr/share/instantthemes/utils/functions.sh || exit 1

THEMECACHEDIR="$HOME/.cache/instantos/themes"
[ -e "$THEMECACHEDIR" ] || {
    mkdir -p "$THEMECACHEDIR" || {
        echo 'failed to create cache directory'
        exit
    }
}

d() {
    RESPONSE="$(dasel -f "$DASELFILE" "$@" || echo valuenotfound)"
    if grep -q 'valuenotfound' <<<"$RESPONSE"; then
        return
    else
        echo "$RESPONSE"
    fi
}

d_default() {
    DASELANSWER="$(d "$2")"
    [ -z "$DASELANSWER" ] && echo "$1"
}

selecttheme() {
    if ! [ -e "$1"/theme.toml ]; then
        echo "theme $1 invalid, missing theme.toml"
        return 1
    fi
    DASELFILE="$(realpath "$1/theme.toml")"
}

installfolder() {
    if [ -e ./"$1"/ ]; then
        [ -d ~/"$2" ] || mkdir -p ~/."$2"
        cp -r ./"$1"/* ~/"$2"/ || echo "failed to install $3"
    else
        return 1
    fi
}

installtheme() {
    selecttheme "$1" || return 1
    pushd "$1" || exit 1

    # install pacman dependencies
    instantinstall $(d 'dependencies' | sed 's/\[//g' | sed 's/\]//g')

    if [ -e ./assets/ ]; then
        pushd assets || exit 1

        installfolder icons icons icons && gtk-update-icon-cache

        installfolder themes themes themes
        installfolder fonts .local/share/fonts fonts && fc-cache -fv
        # TODO: wallpapers
        # TODO: qt themes
        # TODO: kvantum themes

        popd || exit 1
    fi

    popd || exit 1

}

applytheme() {
    selecttheme "$1" || return 1
    DEFAULTVARIANT="$(d_default light defaultvariant)"
    VARIANT="${2:-$DEFAULTVARIANT}"
    setcursor "$(d cursor.theme)"
    # TODO cursor size

    FONTNAME="$(d font.name)"
    if [ -z "$FONTNAME" ]; then
        setgtkfont "$FONTNAME $(d_default 12 font.size)"
    fi

    setgtkicons "$(d icons."$VARIANT")"
    setgtktheme "$(d gtk."$VARIANT".theme)"

    # TODO: qt theme

}

case $1 in
help)
    echohelp
    ;;
install)
    shift 1
    installtheme "$1"
    ;;

esac

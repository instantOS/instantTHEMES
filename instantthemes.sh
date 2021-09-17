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
    # TODO: wallpaper

    if [ -e ./dotfiles ]; then
        pushd dotfiles || exit 1
        [ -e ./"$VARIANT" ] && imosid apply ./"$VARIANT"
        [ -e ./multi/ ] && imosid apply ./multi
        popd || exit 1
    fi

}

# parse argument string into directory location of theme root
gettheme() {
    # locally installed theme
    if [ -e ~/.config/instantos/themes/"$1"/theme.toml ]; then
        realpath ~/.config/instantos/themes/"$1"
        return
    fi

    if [ -e "$1"/theme.toml ]; then
        realpath "$1"
        return
    fi

    # TODO: archive support
    # TODO: https download support
    # TODO: ipfs download support

    export GIT_ASKPASS="instantthemes"
    if git ls-remote --exit-code "$1" &>/dev/null; then
        pushd ~/.config/instantos/themes || exit 1
        git clone "$1" &>/dev/null || return 1
        [ -e "$(basename "$1")/theme.toml" ] || return 1
        realpath "$(basename "$1")"
        popd || exit 1
    fi

    if [ -e /usr/share/instantthemes/themes/"$1"/theme.toml ]; then
        echo /usr/share/instantthemes/themes/"$1"
    fi

    # TODO: version detection/update theme

}

case $1 in
apply)
    # TODO: variant stuff
    applytheme "$(gettheme "$2")"
    ;;
init)
    echo "TODO: theme creation wizard"
    ;;
status)
    echo "TODO: status"
    ;;
variant)
    echo "TODO: variant"
    echo 'dark/light/auto'
    ;;
install)
    shift 1
    installtheme "$(gettheme "$2")"
    ;;
help)
    echohelp
    ;;
esac
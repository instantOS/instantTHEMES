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
        installfolder wallpapers .local/share/wallpapers wallpapers

        popd || exit 1
    fi

    popd || exit 1

}

applytheme() {
    selecttheme "$1" || return 1
    # TODO: record current theme config
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
        THEMERETURNPATH="$(realpath ~/.config/instantos/themes/"$1")"
        return
    fi

    if [ -e "$1"/theme.toml ]; then
        realpath "$1"
        return
    fi

    if [ -f "$1" ]; then
        THEMEARCHIVEPATH="$(realpath "$1")"
        export THEMEARCHIVEPATH
    else
        mkdir -p "/tmp/instantthemesdownload"
        pushd /tmp/instantthemesdownload || exit 1
        [ -e download.tmp ] && rm download.tmp
        if grep -q '^https://' <<<"$1"; then
            curl "$1" >download.tmp
        fi
        if grep -q '^ipfs://' <<<"$1"; then
            IPFSCID="$(echo "$1" | grep -o '[^/]*$')"
            if command -v ipfs; then
                ipfs get "$IPFSCID" -o "download.tmp"
            else
                curl "http://ipfs.io/ipfs/$IPFSCID" >download.tmp
            fi
        fi
        [ -e ./download.tmp ] && THEMEARCHIVEPATH="$(realpath download.tmp)"

        popd || exit 1
    fi

    # extract theme from archive
    if [ -n "$THEMEARCHIVEPATH" ] && [ -f "$THEMEARCHIVEPATH" ]; then
        if atool -c "$THEMEARCHIVEPATH" 'theme.toml' | grep -q 'name'; then
            if [ -e ~/.config/instantos/themes/"$THEMENAME" ]; then
                echo 'overriding existing theme installation'
                rm -rf ~/.config/instantos/themes/"$THEMENAME"
            fi
            atool -X "$THEMEARCHIVEPATH" ~/.config/instantos/themes/"$THEMENAME"
            THEMERETURNPATH="$(realpath ~/.config/instantos/themes/"$THEMENAME")"
        else
            echo 'theme archive invalid'
            exit 1
        fi
    fi

    export GIT_ASKPASS="instantthemes"
    checkgit() {
        if git ls-remote --exit-code "$1" &>/dev/null; then
            pushd ~/.config/instantos/themes || exit 1
            git clone --depth 1 "$1" &>/dev/null || return 1
            [ -e "$(basename "$1")/theme.toml" ] || return 1
            GITTHEMEPATH="$(realpath "$(basename "$1")")"
            popd || exit 1
        fi

    }

    checkgit "$1"
    export THEMERETURNPATH
    [ -n "$GITTHEMEPATH" ] && THEMERETURNPATH="$GITTHEMEPATH" && return
    checkgit "https://github.com/$1"
    [ -n "$GITTHEMEPATH" ] && THEMERETURNPATH="$GITTHEMEPATH" && return
    checkgit "https://gitlab.com/$1.git"
    [ -n "$GITTHEMEPATH" ] && THEMERETURNPATH="$GITTHEMEPATH" && return

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

    # TODO: current
    # theme
    # variant
    # version

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

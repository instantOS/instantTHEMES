#!/bin/bash

# functions used in instantTHEMES

#########################
### General utilities ###
#########################

# checks if either a theme or icon set exists in folder $1
gtkloop() {
    cd "$1" || exit
    echo "$1"
    for i in ./*; do
        [ -e "$i"/index.theme ] || continue
        grep -iq "Name.*=$2.*" ./"$i"/index.theme && return 0
    done
    return 1
}

echohelp() {
    echo 'Usage: instantthemes <command> [options...]

Commands:
    apply <theme name>
        applies a theme to the system
    install <theme location>
        install a theme from a specified location. this can be an archive or
        folder containing the theme or a git repository
    variant <dark/light/auto/default>
        select the theme variant to be used. auto switches themes depending on
            the time of day. default uses the variant specified by the theme
    status
        show information about the current theming
    init
        start a wizard to create a new theme
        (not implemented yet)
    list
        list installed themes
    help
        show this message
    query
        run dasel query command on current theme
    '
}

######################
### Font utilities ###
######################

listtermfonts() {
    fc-list -f "%{family} : %{file}\n" :spacing=100 | sort | less
}

fontexists() {
    if convert -list font | grep -iq "$1"; then
        echo "font $1 exists"
        return 0
    else
        echo "font $1 not found"
        return 1
    fi
}

# set gtk font
setgtkfont() {
    # check for / create gtk 3 settings
    gtk3settings
    [ -z "$1" ] && return
    # set gtk3 settings
    if grep -q 'gtk-font-name' ~/.config/gtk-3.0/settings.ini; then
        sed -i 's/gtk-font-name=.*/gtk-font-name='"$1"'/g' ~/.config/gtk-3.0/settings.ini
    else
        echo "gtk-font-name=$1" >>~/.config/gtk-3.0/settings.ini
    fi

    [ -e ~/.gtkrc-2.0 ] && touch ~/.gtkrc-2.0
    if grep -q 'gtk-font-name' ~/.gtkrc-2.0; then
        sed -i 's/gtk-font-name =.*/gtk-font-name = "'"$1"'"/g' ~/.gtkrc-2.0
    else
        echo 'gtk-font-name = "'"$1"'"' >>~/.gtkrc-2.0
    fi
    # TODO: gtk 4

}

gtkdocumentfont() {
    dconf write '/org/mate/desktop/interface/document-font-name' "'$1'"
}

# Deprecated
fetchfont() {
    mkdir -p ~/.local/share/fonts &>/dev/null
    mkdir -p /tmp/instantosfonts/"$1"
    cd /tmp/instantosfonts/"$1" || return 1

    echo "downloading font $1"
    case "$2" in
    google)
        wget -qO font.zip "https://fonts.google.com/download?family=$3"
        unzip font.zip
        rm LICENSE.txt
        rm font.zip
        ;;
    script)
        if [ -e /usr/share/instantthemes/scripts/"$3".sh ]; then
            /usr/share/instantthemes/scripts/"$3".sh
        fi
        ;;
    esac

    if ! ls | grep -q '..'; then
        echo 'font download failed'
        return 1
    fi
    mv ./* ~/.local/share/fonts

    rm -rf /tmp/instantosfonts
}

installfont() {
    if tparse q "$1".font.name && ! fontexists "$(tparse "$1".font.name)"; then
        if tparse q "$1".font.googlesource; then
            fetchfont google "$(tparse "$1".font.googlesource)" || return 1
        elif tparse q "$1".font.scriptsource; then
            fetchfont script "$(tparse "$1".font.scriptsource)" || return 1
        fi
    fi
}

###########################
### GTK theme utilities ###
###########################

# initializes gtk3 config files
gtk3settings() {
    if ! [ -e ~/.config/gtk-3.0/settings.ini ]; then
        mkdir -p ~/.config/gtk-3.0
        echo "[Settings]" >~/.config/gtk-3.0/settings.ini
    fi

    # disable window decorations because they don't work on instantWM
    if pgrep instantwm &>/dev/null; then
        if ! grep -q 'gtk-decoration-layout' ~/.config/gtk-3.0/settings.ini; then
            echo 'gtk-decoration-layout=appmenu:none' >>~/.config/gtk-3.0/settings.ini
        fi
    fi

}

setgtktheme() {
    gtk3settings
    [ -z "$1" ] && return
    # set gtk3 settings
    if [ -e ~/.config/gtk-3.0/settings.ini ] && grep -q 'gtk-theme-name' ~/.config/gtk-3.0/settings.ini; then
        if grep -q "gtk-theme-name=$1$" ~/.config/gtk-3.0/settings.ini; then
            echo "gtk theme already applied"
            return
        else
            sed -i 's/gtk-theme-name=.*/gtk-theme-name='"$1"'/g' ~/.config/gtk-3.0/settings.ini
        fi
    else
        echo "gtk-theme-name=$1" >>~/.config/gtk-3.0/settings.ini
    fi

    if [ -e ~/.gtkrc-2.0 ] && grep -q 'gtk-theme-name' ~/.gtkrc-2.0; then
        sed -i 's/gtk-theme-name =.*/gtk-theme-name = "'"$1"'"/g' ~/.gtkrc-2.0
    else
        echo 'gtk-theme-name = "'"$1"'"' >>~/.gtkrc-2.0
    fi

}

# check if gtk theme is installed on system
themeexists() {
    if { gtkloop "$HOME/.themes" "$1" ||
        gtkloop '/usr/share/themes' "$1"; }; then
        echo "theme $1 exists"
        return 0
    else
        echo "theme $1 doesnt exist"
        return 1
    fi
}

installgtktheme() {
    if tparse "$1".pacmansource; then
        instantinstall "$(tparse "$1".pacmansource)"
    elif tparse q "$1".gitsource; then
        THEMEGITSOURCE="$(tparse "$1".gitsource)"

        mkdir -p /tmp/instantostemptheme
        cd /tmp/instantostemptheme || return 1
        notify-send "installing gtk theme $1"

        if grep -q '://' <<<"$THEMEGITSOURCE"; then
            # full link
            git clone --depth=1 "$THEMEGITSOURCE" temptheme
        else
            # default to github
            git clone --depth=1 "https://github.com/$THEMEGITSOURCE" temptheme
        fi

        cd temptheme || return 1
        if [ -e ./install.sh ]; then
            ./install.sh
        elif [ -e ./Install.sh ]; then
            ./install.sh
        fi
        rm -rf /tmp/instantostemptheme
    fi

}

##########################
### GTK icon utilities ###
##########################

setgtkicons() {
    [ -z "$1" ] && return
    if [ -e ~/.config/qt5ct/qt5ct.conf ]; then
        if grep -q "icon_theme=$1$" ~/.config/qt5ct/qt5ct.conf; then
            echo "qt icons already applied"
        else
            sed -i 's/icon_theme=.*/icon_theme='"$1"'/g' ~/.config/qt5ct/qt5ct.conf
        fi
    fi

    gtk3settings
    if grep -q 'gtk-icon-theme-name' ~/.config/gtk-3.0/settings.ini; then
        if grep -q "gtk-icon-theme-name=$1$" ~/.config/gtk-3.0/settings.ini; then
            echo "gtk icons already applied"
        else
            sed -i 's/gtk-icon-theme-name=.*/gtk-icon-theme-name='"$1"'/g' ~/.config/gtk-3.0/settings.ini
        fi
    else
        echo "gtk-icon-theme-name=$1" >>~/.config/gtk-3.0/settings.ini
    fi

    if grep -q 'gtk-icon-theme-name' ~/.gtkrc-2.0; then
        if grep -q 'gtk-icon-theme-name = "'"$1"'"$' ~/.gtkrc-2.0; then
            echo "gtk2 theme already applied"
        else
            sed -i 's/gtk-icon-theme-name =.*/gtk-icon-theme-name = "'"$1"'"/g' ~/.gtkrc-2.0
        fi
    else
        echo 'gtk-icon-theme-name = "'"$1"'"' >>~/.gtkrc-2.0
    fi

}

# check if gtk icon theme is installed on systems
icons_exist() {
    if { gtkloop "$HOME/.icons" "$1" ||
        gtkloop '/usr/share/icons' "$1" ||
        gtkloop "$HOME/.local/share/icons" "$1"; }; then

        echo "icons $1 exist"
        return 0
    else
        echo "icons $1 dont exist"
        return 1
    fi
}

# install cursor from github
papercursor() {
    echo "fetching paper cursor"
    if ! [ -e ~/.icons/"$1" ]; then
        mkdir ~/.icons &>/dev/null
        cd ~/.icons || return 1
        instantinstall subversion || return 1
        svn export "https://github.com/paperbenni/cursors.git/trunk/$1"
    fi
}

# set cursor in gtk and xorg
setcursor() {
    [ -z "$1" ] || return
    echo "setting cursor to $1"
    mkdir -p ~/.icons/default &>/dev/null

    {
        echo "# This file is written by instantthemes. Do not edit."
        echo "[Icon Theme]"
        echo "Name=Default"
        echo "Comment=Default Cursor Theme"
        echo "Inherits=$1"

    } >~/.icons/default/index.theme

    if [ -e ~/.Xresources ]; then
        if grep -q 'Xcursor.theme: ' ~/.Xresources; then
            imosid check ~/.Xresources && COMPILEXRESOURCES="true"
            sed -i 's/Xcursor.theme: .*/Xcursor.theme: '"$1"'/g'
            [ -n "$COMPILEXRESOURCES" ] && imosid compile ~/.Xresources
        else
            # newline is needed because its missing in the default Xresources
            echo "
Xcursor.theme: $1" >>~/.Xresources
            imosid compile ~/.Xresources
        fi
    fi
}

######################
# QT theme utilities #
######################

setqttheme() {
    [ -z "$1" ] && return
    [ -e ~/.config/qt5ct/qt5ct.conf ] || return 1
    sed 's/^style=.*/style='"$1"'/g'
}

kvantumsettings() {
    [ -e ~/.config/Kvantum/kvantum.kvconfig ] || return
    mkdir -p ~/.config/Kvantum
    {
        echo '[General]'
        echo 'theme=Breeze'
    } >~/.config/Kvantum/kvantum.kvconfig
}

setkvantumtheme() {
    [ -z "$1" ] && return
    kvantumsettings
    sed -i 's/^theme=*/theme='"$1"'/g' ~/.config/Kvantum/kvantum.kvconfig
}


###################
# Theme utilities #
###################


getvariant(){
    CONFIGVARIANT="$(iconf themevariant)"

    case "$CONFIGVARIANT" in
        light)
            echo light
            ;;
        dark)
            echo dark
            ;;
        *)
            # auto detect if not set or corrupted
            HOUR="$(date +%H)"
            if [ "$HOUR" -gt 19 ] || [ "$HOUR" -lt 6 ]
            then
                echo dark
            else
                echo light
            fi
            ;;
    esac

}




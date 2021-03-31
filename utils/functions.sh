#!/bin/bash

# functions used in instantTHEMES

#########################
### General utilities ###
#########################

tparse() {
    if [ "$1" = "q" ]; then
        shift 1
        yq ".theme.${1}" <"$THEMEFILE" &>/dev/null || return 1
    else
        yq ".theme.${1}" <"$THEMEFILE" &>/dev/null || return 1
    fi
}

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

}

gtkdocumentfont() {
    dconf write '/org/mate/desktop/interface/document-font-name' "'$1'"
}

checkfont() {
    if convert -list font | grep -iq "$1"; then
        echo "font $1 is installed"
        return 0
    else
        echo "font $1 not found"
        return 1
    fi
}

fetchfont() {
    mkdir -p ~/.local/share/fonts &>/dev/null
    mkdir -p /tmp/instantosfonts/"$1"
    cd /tmp/instantosfonts/"$1" || return 1

    echo "downloading font $1"
    # TODO: other sources
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

    mv ./* ~/.local/share/fonts
    popd || exit 1

    rm -rf /tmp/instantosfonts
}

installfont() {
    if tparse q "$1".font.name && ! fontexists "$(tparse "$1".font.name)"; then
        if tparse q "$1".font.googlesource; then
            fetchfont google "$(tparse "$1".font.googlesource)"
        elif tparse q "$1".font.scriptsource; then
            fetchfont script "$(tparse "$1".font.scriptsource)"
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
        instantinstall "$("$1".pacmansource)"
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
        instantinstall svn || return 1
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
        app "[Icon Theme]"
        app "Name=Default"
        app "Comment=Default Cursor Theme"
        app "Inherits=$1"

    } >~/.icons/default/index.theme

    if [ -e ~/.Xresources ]; then
        if grep -q 'Xcursor.theme: ' ~/.Xresources; then
            sed -i 's/Xcursor.theme: .*/Xcursor.theme: '"$1"'/g'
        else
            # newline is needed because its missing in the default Xresources
            echo "
Xcursor.theme: $1" >>~/.Xresources
        fi
    fi
}

# copies a rofi theme config
rofitheme() {
    [ -z "$1" ] || return

    echo "Setting rofi theme to $1"
    mkdir -p ~/.config/rofi &>/dev/null
    cat /usr/share/instantdotfiles/rofi/"$1".rasi >~/.config/rofi/"$1".rasi

    echo "configuration {" >~/.config/rofi/config.rasi
    echo "theme: \"~/.config/rofi/$1.rasi\";" >>~/.config/rofi/config.rasi
    echo "}" >>~/.config/rofi/config.rasi
}

dunsttheme() {
    export DUNSTRC="$HOME/.config/dunst/dunstrc"

    if [ -e "$DUNSTRC" ]; then
        # remove previous theme
        if grep -q instantTHEMES "$DUNSTRC"; then
            sed -i '/^#.*instantTHEMES.*start/,/^#.*instantTHEMES.*end/d' -i dunstrc
        fi
        if grep -q '\[base16_low\]' "$DUNSTRC" && ! [ "$2" = "-f" ]; then
            echo 'theme is customized, Im not messing with that'
            return 1
        fi
    else
        [ -e ~/.config/dunst ] || mkdir -p ~/.config/dunst
        cat /usr/share/instantdotfiles/dunstrc >"$DUNSTRC"
    fi

    echo '# generated by instantTHEMES start
# REMOVE MARKERS TO MANUALLY EDIT THIS PORTION' >>"$DUNSTRC"
    echo "setting dunst theme to $1"
    cat /usr/share/instantthemes/dunst/"$1" >>~/.config/dunst/dunstrc
    echo '# REMOVE MARKERS TO MANUALLY EDIT THIS PORTION
# generated by instantTHEMES end' >>"$DUNSTRC"

}

# set up xresources
setxtheme() {
    echo "Setting xorg theme to $1"
    if ! [ -e ~/.Xresources ]; then
        echo 'initializing xresources'
        cat /usr/share/instantdotfiles/Xresources >~/.Xresources || {
            echo "please install instantdotfiles"
            return 1
        }
    else
        if ! grep -q instantTHEMES; then
            echo 'no instantthemes marker in xresources found, aborting to avoid overriding user configuration'
            return 1
        else
            echo 'removing previous theme'
            sed -i '/^".*instantTHEMES.*start/,/^".*instantTHEMES.*end/d' -i ~/.Xresources || return 1
        fi
    fi

    {
        echo '! generated by instantTHEMES start
! REMOVE MARKERS TO MANUALLY EDIT THIS PORTION'
        cat /usr/share/instantthemes/xresources/"$1"
        echo '! REMOVE MARKERS TO MANUALLY EDIT THIS PORTION
! generated by instantTHEMES end'
    } >>~/.Xresources

    instantdpi
}

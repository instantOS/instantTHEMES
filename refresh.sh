#!/bin/bash

# refresh themes
echo "refreshing instantOS themes"
if [ -e ~/.config/gtk-3.0/settings.ini ]; then
    GTK3K="$HOME/.config/gtk-3.0/settings.ini"
    if grep -q 'gtk-theme-name' "$GTK3K"; then
        GTKTHEME=$(grep 'gtk-theme-name' "$GTK3K" | grep -o '[^=]*$')
        dconf write /org/gnome/desktop/interface/gtk-theme "'$GTKTHEME'"
        dconf write /org/mate/desktop/interface/gtk-theme "'$GTKTHEME'"
    fi

    if grep -q 'gtk-icon-theme-name' "$GTK3K"; then
        ICONTHEME=$(grep 'gtk-icon-theme-name' "$GTK3K" | grep -o '[^=]*$')
        dconf write /org/gnome/desktop/interface/icon-theme "'$ICONTHEME'"
        dconf write /org/mate/desktop/interface/icon-theme "'$ICONTHEME'"
    fi

    if grep -q 'gtk-font-name' "$GTK3K"; then
        GTKFONT=$(grep 'gtk-font-name' "$GTK3K" | grep -o '[^=]*$')
        dconf write '/org/mate/desktop/interface/font-name' "'$GTKFONT'"
    fi
fi

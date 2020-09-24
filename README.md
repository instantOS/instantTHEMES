<div align="center">
    <h1>instantTHEMES</h1>
    <p>Theming for instantOS</p>
    <img width="300" height="300" src="https://media.githubusercontent.com/media/instantOS/instantLOGO/master/png/theme.png">
</div>

# instantTHEMES

## Theme format

```sh
# name under which the theme is being referred to in config
THEMENAME=arc

# Default gtk theme, used for light mode and if no dark variant is present also
# for dark mode
GTKTHEME="Arc"

# Default gtk icons, used for light mode and if no dark variant is present also
# for dark mode
GTKICONS="Papirus"

# Cursor theme, set in xresources and for gtk
CURSORTHEME="elementary-instantos"

# Font used for Gtk and various other apps
GTKFONT="Cantarell 10,g:Cantarell"

# Dark variants of GTKICONS and GTKTHEME
# are activated with dark mode
DGTKTHEME="Arc-Dark"
DGTKICONS="Papirus-dark"

# name of the xresources file from the repo
# defaults to $THEMENAME
XTHEME=arc

# name of the rofi theme from the repo
# defaults to $THEMENAME
ROFITHEME=arc

# name of the dunst theme from the repo
# defaults to $THEMENAME
DUNSTTHEME=arc

```

--------

### instantOS is still in early beta, contributions always welcome

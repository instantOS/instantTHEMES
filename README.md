<div align="center">
    <h1>instantTHEMES</h1>
    <p>Theming for instantOS</p>
    <img width="300" height="300" src="https://raw.githubusercontent.com/instantOS/instantLOGO/main/png/theme.png">
</div>

# instantTHEMES

## Features

A single theme package for most parts of the OS
- Gtk theme
- Icon theme
- Qt theme
- Cursor
- Fonts

Light/Dark variants with automatic switching between them

[imosid](https://github.com/instantOS/imosid) integration for theming dotfiles

## Usage

### Theme structure

Themes consist of a folder or archive that contains all information and assets for the theme. 

```txt
themename
    theme.toml
    dotfiles
        light
            Xresources
            dunstrc
            ...
        dark
            ...
        multi
            ...
    assets
        fonts
            ...
        themes
            Arc
            ...
        wallpapers
            ...
        icons
            Papirus
            ...
```

### Example config

```toml

name = "instantOS"
version = 0
defaultvariant = "light"
dependencies = ["materia-gtk-theme", "papirus-icon-theme", "instantcursors"]

[cursor]
theme = "elementary-instantos"
size = 16

[font]
name = "Inter"
size = 12

[icons]
light = "Papirus"
dark = "Papirus-Dark"

[gtk]
[gtk.light]
theme = "Materia"
[gtk.dark]
theme = "Materia-dark"

[qt]
[qt.light]
theme = "kvantum"
[qt.dark]
theme = "kvanum-dark"

kvantum = "Materia"
```

## Planned features

- [X] QT theme
- [X] QT icons
- [ ] GTK 4 theme
- [ ] Wallpaper config


--------

### instantOS is still in early beta, contributions always welcome

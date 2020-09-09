#!/bin/bash

source <(curl -Ls https://git.io/JerLG)
pb unpack

mkdir font1
cd font1 || exit 1
wget -q https://developer.apple.com/design/downloads/SF-Font-Pro.dmg
appledmg SF-Font-Pro.dmg
mv Library/Fonts/* ../

mkdir font2
cd font2 || exit 1
wget -q https://developer.apple.com/design/downloads/SF-Mono.dmg
appledmg SF-Mono.dmg
mv Library/Fonts/* ../

rm -rf font1
rm -rf font2

#!/usr/bin/env sh

rm builds/html/*
godot --headless --export-release "HTML5" builds/html/index.html
butler push builds/html chinchillai/pepper-game:html

rm builds/windows/*
godot --headless --export-release "Windows Desktop" builds/windows/peppergame.exe
butler push builds/windows chinchillai/pepper-game:windows

rm builds/linux/*
godot --headless --export-release "Linux/X11" builds/linux/peppergame.x86_64
butler push builds/linux chinchillai/pepper-game:linux

rm builds/osx/*
godot --headless --export-release "macOS" builds/osx/pepper-game-osx.zip
butler push builds/osx chinchillai/pepper-game:osx

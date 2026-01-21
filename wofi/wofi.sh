#!/bin/bash

# 1️⃣ Get list of applications from desktop files
apps=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read f; do
    grep -m1 '^Name=' "$f" | cut -d= -f2
done | sort -u)

# 2️⃣ Get all files/folders from /home (excluding hidden)
files=$(fd . /home 2>/dev/null)

# 3️⃣ Combine apps first, then files/folders, and show in Wofi menu (case-insensitive)
selection=$(printf "%s\n%s" "$apps" "$files" | wofi --dmenu -i -W 300 --style style.css --prompt "Apps & Files" --location 3 -y 40)

# 4️⃣ Open selection
if [ -n "$selection" ]; then
    # Check if it matches an app
    desktop_file=$(grep -ril "^Name=$selection" /usr/share/applications ~/.local/share/applications 2>/dev/null | head -n1)
    if [ -n "$desktop_file" ]; then
        gtk-launch "$(basename "$desktop_file" .desktop)"
    elif [ -d "$selection" ]; then
        # Open folders specifically with Dolphin
        dolphin "$selection" &
    elif [ -f "$selection" ]; then
        # Open files with default app
        xdg-open "$selection"
    fi
fi

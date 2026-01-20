#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

# Path to your theme cursors folder
THEME_DIR="$HOME/.icons/AydamCursors/cursors"
cd "$THEME_DIR"

echo "Creating only hash symlinks in $THEME_DIR..."
echo

# Hash -> cursor mapping (from example theme)
declare -A HASHES
HASHES[00008160000006810000408080010102]=v_double_arrow
HASHES[028006030e0e7ebffc7f7070c0600140]=h_double_arrow
HASHES[03b6e0fcb3499374a867c041f52298f0]=crossed_circle
HASHES[08e8e1c95fe2fc01f976f1e063a24ccd]=left_ptr_watch
HASHES[14fef782d02440884392942c11205230]=sb_h_double_arrow
HASHES[2870a09082c103050810ffdffffe0204]=sb_v_double_arrow
HASHES[c7088f0f3e6c8088236ef8e1e3e70000]=bd_double_arrow
HASHES[e29285e634086352946a0e7090d73106]=hand2
HASHES[fcf1c3c7cd4491d801f1e1c78f100000]=fd_double_arrow
HASHES[d9ce0ab605698f320427677b458ad60b]=question_arrow
HASHES[9d800788f1b08800ae810202380a0822]=hand2
HASHES[4498f0e0c1937ffe01fd06f973665830]=move
HASHES[3ecb610c1bf2410f44200f48c40d3599]=left_ptr_watch
HASHES[3085a0e285430894940527032f8b26df]=link
HASHES[6407b0e94181790501fd1e167b474872]=copy
HASHES[640fb0e74195791501fd1ed57b41487f]=link
HASHES[9081237383d90e509aa00f00170e968f]=move

# Create only hash symlinks
for hash in "${!HASHES[@]}"; do
  src="${HASHES[$hash]}"
  if [[ -e "$src" && "$hash" != "$src" ]]; then
    ln -sf "$src" "$hash"
    echo "Linked hash: $hash -> $src"
  elif [[ "$hash" == "$src" ]]; then
    echo "Skipped self-link: $hash -> $src"
  else
    echo "Skipped missing source: $hash -> $src"
  fi
done

echo
echo "All done! Only hash symlinks created."

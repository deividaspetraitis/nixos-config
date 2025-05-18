sed -i "s|/nix/store[^ ]*/bin/nvim --cmd[^ ]* [^ ]* [^ ]*|nvim|" $1
sed -i "s|/run/current-system/sw/bin/||g" $1

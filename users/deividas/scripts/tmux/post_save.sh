# Post save hook script for NixOS
# This script is executed after ~/.tmux/resurrect/last is saved to disk.
# It is used to clean up paths to binaries so tmux can restore the session.

sed -i "s|/nix/store[^ ]*/bin/nvim --cmd[^ ]* [^ ]* [^ ]*|nvim|" $1 # nvim
sed -i "s|/run/current-system/sw/bin/||g" $1 # general binaries
sed -ie "s|:bash .*/tmp/nix-shell-.*/rc|:nix-shell|g" $1 # nix-shell

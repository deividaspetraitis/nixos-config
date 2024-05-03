sed -ie "s| --cmd .*-vim-pack-dir||g" $1
sed -i "s|/nix/store/\(.*\)/bin/||g" $1
sed -i "s|/run/current-system/sw/bin/||g" $1

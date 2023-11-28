{ pkgs }:
{
  packageOverrides = pkgs: with pkgs; {
    myVim = vim-full.customize {
      # `name` specifies the name of the executable and package
      name = "vim-with-plugins";
      # add here code from the example section
    };
    myNeovim = neovim.override {
      configure = {
      # add code from the example section here
      };
    };
  };
}

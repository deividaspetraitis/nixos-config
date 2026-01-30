{ config, pkgs, pkgs-stable, xdg, inputs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "cerberus";
  home.homeDirectory = "/home/cerberus";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # Permitted list of insecure packages.
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
  ];


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".config/zsh" = { source = ../../.dotfiles/zsh; recursive = true; };
    ".config/nvim" = { source = ../../.dotfiles/nvim; recursive = true; };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or

  #  /etc/profiles/per-user/cerberus/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.

  home.sessionVariables = {
    # Default editor
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Enable NeoVim.
  programs.neovim = {
    enable = true;
    extraConfig = lib.fileContents ../../.dotfiles/nvim/init.lua;
    package = pkgs.neovim-unwrapped;
    plugins = with pkgs; [
    ];
    extraPackages = with pkgs; [
      cargo
    ];
  };

  # Enable Git & Git LFS
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # Z Shell configuration.
  programs.zsh = {
    # Whether to enable Z Shell or not.
    enable = true;

    shellAliases = {
      # Nix related
      switch-all = "switch-host && switch-home";
    };

    history = {
      # Maximum history events for history file 
      save = 100000;

      # Share command history between sessions.
      share = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

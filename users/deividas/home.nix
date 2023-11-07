{ config, pkgs, xdg, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "deividas";
  home.homeDirectory = "/home/deividas";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.alacritty
    pkgs.tmux
    pkgs.git
    pkgs.git-crypt
    pkgs.gnupg
    pkgs.pinentry_qt
    pkgs.qutebrowser-qt6
    pkgs.firefox
    pkgs.chromium
    pkgs._1password
    pkgs._1password-gui
    pkgs.pcmanfm
    pkgs.nix-prefetch-github

    # Go related packages
    pkgs.go
    pkgs.gopls
    pkgs.golangci-lint

    #  Required by zplug
    pkgs.python3

    # fzf is used in shell
    pkgs.fzf
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".vim".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/.vim";
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/.tmux.conf";
    ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/.gitconfig";
    # ".config/sway".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/sway";
    ".config/qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/qutebrowser";
    ".config/foot".source = config.lib.file.mkOutOfStoreSymlink "/home/deividas/.dotfiles/foot";

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
  
  #  /etc/profiles/per-user/deividas/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.

  home.sessionVariables = {
    # Default editor
    EDITOR = "vim";
    VISUAL = "vim";

    # Dot files directory
    DOTDIR = "/home/deividas/.dotfiles";
  };

  # XDG are defaults for some of the programs.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Set vim as default editor
  programs.vim.defaultEditor = true;

  # Enable GPG
  programs.gpg = {
    enable = true;
  };

  # Z Shell configuration.
  programs.zsh = {
    # Whether to enable Z Shell or not.
    enable = true;

    initExtra = ''
      # Options
      # More options: https://zsh.sourceforge.io/Doc/Release/Options.html
      setopt AUTO_PARAM_SLASH
      unsetopt CASE_GLOB
      
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      # Enable Vi mode
      bindkey -v
      bindkey "^?" backward-delete-char # Fix modes N -> I -> I backspace  not working
      
      export KEYTIMEOUT=1 # timeout for switching between INSERT/NORMAL modes
      
      # Enable CTRL-P CTRL-N
      bindkey "^P" up-line-or-search
      bindkey "^N" down-line-or-search
      
      # vi-yank-clip is OS specific
      zle -N vi-yank-clip
      bindkey -M vicmd 'y' vi-yank-clip

      # Edit command line in Vim
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line

      # Autocomplete hidden files
      _comp_options+=(globdots)

      # Enable fzf in zsh.
      # fzf provides additional key bindings (CTRL-T, CTRL-R, and ALT-C) for shells  
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
   '';

   shellAliases = {
     switch-user = "nix build '/home/deividas/nix-config/.#homeManagerConfigurations.deividas.activationPackage' --out-link /home/deividas/nix-config/result && /home/deividas/nix-config/result/activate";

     switch-system = "sudo nixos-rebuild switch --flake '/home/deividas/nix-config/.#'";
     update-system = "nix flake update --commit-lock-file /home/deividas/nix-config";
   };

   history = {
     # Maximum history events for history file 
     save = 100000;

     # Share command history between sessions.
     share = true;
   };

    
    # Named directory hash table.
    dirHashes = {
      docs  = "$HOME/Documents";
      vids  = "$HOME/Videos";
      dl    = "$HOME/Downloads";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zpm-zsh/colorize"; }
        { name = "owenvoke/quoter-zsh"; }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; tags = [ defer:2 ]; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };

    ## Plugins to source
    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./. +  "/zsh";
        file = ".p10k.zsh";
      }
    ];
  };

  # Enable GPG Agent
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

{ config, pkgs, pkgs-stable, xdg, lib, ... }:

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

  # Permitted list of insecure packages.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";

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
    pkgs.gnumake
    pkgs.gcc
    pkgs.tmux
    pkgs.git
    pkgs.act
    pkgs.git-crypt
    pkgs.qutebrowser
    pkgs.pcmanfm
    pkgs.vifm
    pkgs.nix-prefetch-github
    pkgs.wrk
    pkgs.jq
    pkgs.obsidian

    pkgs.synology-drive-client

    # Go related packages
    pkgs.go
    pkgs.delve
    pkgs.rr
    pkgs.golangci-lint

    # Useful utilities
    pkgs.usbutils
    pkgs.unzip 
    pkgs.lz4
    pkgs.graphviz
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".tmux.conf" = { source = ../../.dotfiles/.tmux.conf; recursive = false;  };
    ".gitconfig" = { source = ../../.dotfiles/.gitconfig; recursive = false; };
    ".config/gitconfig" = { source = ../../.dotfiles/gitconfig; recursive = true; };
    ".config/qutebrowser" = { source = ../../.dotfiles/qutebrowser; recursive = true; };
    ".config/vifm" = { source = ../../.dotfiles/vifm; recursive = true; };
    ".config/foot" = { source = ../../.dotfiles/foot; recursive = true; };
    ".config/zsh" = { source = ../../.dotfiles/zsh; recursive = true; };

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
  };

  # Extra directories to add to PATH.
  # These directories are added to the PATH variable in adouble-quoted context, so expressions like $HOME are
  # expanded by the shell. However, since expressions like ~ or* are escaped, they will end up in the PATH verbatim.
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  # XDG are defaults for some of the programs.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Set vim as default editor
  # TODO
  # programs.vim = {
  #   enable = true;
  #   defaultEditor = true;
  # };

  # Enable GPG
  programs.gpg = {
    enable = true;
  };

  # SSH client configuration
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };

  # GitHub CLI tool
  programs.gh = {
    enable = true;
    settings = {
      editor = "vim";
      protocol = "ssh";
    };
  };

  # Enable GPG Agent
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    defaultCacheTtl = 46000;
    extraConfig = ''
      allow-preset-passphrase
    '';
  };

  # fzf is a general-purpose command-line fuzzy finder.
  programs.fzf = {
    # Enable fzf - a command-line fuzzy finder.
    enable = true;

    # Enable fzf in zsh
    # fzf provides additional key bindings (CTRL-T, CTRL-R, and ALT-C) for shells  
    enableBashIntegration = true;
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

      # Disable sharing history across different panes.
      setopt nosharehistory

      # Enable extended globbing
      setopt EXTENDED_GLOB

      # Enable Vi mode
      bindkey -v
      bindkey "^?" backward-delete-char # Fix modes N -> I -> I backspace  not working
      
      export KEYTIMEOUT=1 # timeout for switching between INSERT/NORMAL modes
      
      # Enable CTRL-P CTRL-N
      bindkey "^P" up-line-or-search
      bindkey "^N" down-line-or-search
      
      # By default zsh yanks to its own internal registers.
      # Luckily, like in Vim, it's fairly simple yank to the system clipboard.
      function vi-yank-clip {
          zle vi-yank
          echo "$CUTBUFFER" | wl-copy # wl-copy is OS specific
      }
      zle -N vi-yank-clip
      bindkey -M vicmd 'y' vi-yank-clip

      # Edit command line in Vim
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line

      # Autocomplete hidden files
      _comp_options+=(globdots)

      # Start tmux on every shell login
      if pgrep --exact sway > /dev/null 2>&1 && [[ -z "$TMUX" ]]; then
          tmux attach || tmux new-session
      fi

      # add ~/.config/zsh/external to fpath, and then lazy autoload
      # every file in there as a function
      fpath=(~/.config/zsh/external $fpath);
      autoload -U $fpath[1]/*(-.:t)
   '';

   shellAliases = {
     # Nix related
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

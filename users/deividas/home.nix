{ config, pkgs, pkgs-stable, xdg, inputs, lib, ... }:

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

  # Enable flakes
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Mime apps configuration
  xdg.mimeApps = {
    # Whether to manage {file}$XDG_CONFIG_HOME/mimeapps.list.
    enable = true;

    # The default application to be used for a given mimetype. 
    defaultApplications = {
      "text/html" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
    };
  };

  # XDG are defaults for some of the programs.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  #  Desktop Entries allow applications to be shown in your desktop environment's app launcher.
  xdg.desktopEntries = {
    pulsemixer = {
      name = "Pulsemixer";
      genericName = "Volume Mixer";
      icon = "audio-volume-high-symbolic";
      type = "Application";
      terminal = true;
      exec = "${pkgs.raiseorrun}/bin/raiseorrun --app_id pulsemixer --title pulsemixer -- pulsemixer";
      categories = [ "Audio" ];
    };
    bluetui = {
      name = "Bluetui";
      genericName = "Bluetooth Manager";
      icon = "bluetui";
      type = "Application";
      terminal = true;
      categories = [ "Utility" "Settings" "ConsoleOnly" ];
      exec = "${pkgs.raiseorrun}/bin/raiseorrun --app_id bluetui --title bluetui -- bluetui";
    };
    vifm = {
      name = "Vifm";
      genericName = "File Manager";
      comment = "Vim-like ncurses based file manager";
      icon = "vifm";
      type = "Application";
      terminal = true;
      categories = [ "System" "FileManager" "Utility" "ConsoleOnly" ];
      exec = "${pkgs.raiseorrun}/bin/raiseorrun --app_id vifm --title vifm -- vifm";
    };
    htop = {
      name = "Htop";
      comment = "Show System Processes";
      genericName = "Process Viewer";
      icon = "htop";
      type = "Application";
      terminal = true;
      categories = [ "System" "Monitor" "ConsoleOnly" ];
      exec = "${pkgs.raiseorrun}/bin/raiseorrun --app_id htop --title htop -- htop";
    };
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
    (import ./scripts/osmostat.nix { inherit pkgs; })
    (import ./scripts/osmodenomliq.nix { inherit pkgs; })
    (import ./scripts/osmodenom.nix { inherit pkgs; })

    # Adjusts your screen to emit warmer light based on the time of day
    pkgs.openssl
    pkgs.gnumake
    pkgs.gcc
    pkgs.act
    pkgs.git-crypt
    pkgs.pcmanfm
    pkgs.nix-prefetch-github
    pkgs.wrk
    pkgs.jq
    pkgs.jd-diff-patch
    pkgs.yq
    pkgs.ripgrep
    pkgs.obsidian
    pkgs.jellyfin-ffmpeg
    pkgs.synology-drive-client
    pkgs.telegram-desktop
    pkgs.discord
    pkgs.slack
    pkgs.ledger-live-desktop
    pkgs.direnv

    # Screen color temperature manager
    pkgs.gammastep

    # VPNs
    pkgs-stable.protonvpn-gui
    pkgs.wireguard-tools

    # Browsers
    pkgs.qutebrowser
    pkgs.chromium
    pkgs.brave

    # Networking
    pkgs.nmap

    # Lmstudio
    pkgs.lmstudio

    # Go related packages
    pkgs.go
    pkgs.protobuf
    pkgs.delve
    pkgs.rr
    pkgs-stable.golangci-lint

    # Event-driven I/O framework for the V8 JavaScript engine
    # programs: corepack node npm npx
    pkgs.nodejs

    # The Rust toolchain installer
    pkgs.rustup

    # Python
    (pkgs.python3.withPackages (ps: with ps; [
      ps.jupyter
      # ps.ledgerwallet # Library to control Ledger devices, disabled due to CVE-2024-23342
    ]))

    # DevOps
    pkgs.lychee
    pkgs.teleport
    pkgs.kubectl
    pkgs.k9s
    pkgs-stable.datadog-agent
    pkgs.nixos-generators
    pkgs.sops

    # Media players
    pkgs.audacious
    pkgs.vlc

    # Useful utilities
    pkgs.file
    pkgs.usbutils
    pkgs.unzip
    pkgs.lz4
    pkgs.pv
    pkgs.graphviz
    pkgs.fastfetch
    pkgs.unixtools.xxd
    pkgs.caligula
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".gitconfig" = { source = ../../.dotfiles/.gitconfig; recursive = false; };
    ".config/gitconfig" = { source = ../../.dotfiles/gitconfig; recursive = true; };
    ".config/qutebrowser" = { source = ../../.dotfiles/qutebrowser; recursive = true; };
    ".config/vifm" = { source = ../../.dotfiles/vifm; recursive = true; };
    ".config/rofi" = { source = ../../.dotfiles/rofi; recursive = true; };
    ".config/foot" = { source = ../../.dotfiles/foot; recursive = true; };
    ".config/zsh" = { source = ../../.dotfiles/zsh; recursive = true; };
    ".config/hypr" = { source = ../../.dotfiles/hypr; recursive = true; };
    ".config/nvim" = { source = ../../.dotfiles/nvim; recursive = true; };
    ".config/gammastep" = { source = ../../.dotfiles/gammastep; recursive = true; };
    ".vim/after" = { source = ../../.dotfiles/vim/after; recursive = true; };

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
    # Reference OpNix-managed secrets in environment
    ANTHROPIC_API_KEY = "$(cat /run/secrets/anthropic/api-key)";

    # Default editor
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Extra directories to add to PATH.
  # These directories are added to the PATH variable in adouble-quoted context, so expressions like $HOME are
  # expanded by the shell. However, since expressions like ~ or* are escaped, they will end up in the PATH verbatim.
  home.sessionPath = [
    "$HOME/go/bin"
  ];

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


  imports = [ inputs._1password-shell-plugins.hmModules.default ];

  # Enable and setup 1Password shell plugins
  programs._1password-shell-plugins = {
    # enable 1Password shell plugins for bash, zsh, and fish shell
    enable = true;
    # the specified packages as well as 1Password CLI will be
    # automatically installed and configured to use shell plugins
    plugins = with pkgs; [ gh ];
  };

  # Tmux setup
  programs.tmux = {
    enable = true;

    # Set the prefix key. Overrules the "shortcut" option when set.
    prefix = "C-s";

    # My keyboard starts numbering from 1..9..0 but not 0..1..9 which makes default
    # base-index of 0 weird to reach when switching between the windows.
    baseIndex = 1;

    # Set the $TERM variable.
    terminal = "tmux-256color";

    # Time in milliseconds for which tmux waits after an escape is input.
    # Default escape time of 1s is not acceptable as a Vim user in order to be capable
    # quickly get out of insert mode.
    escapeTime = 10;

    # Set VI style shortcuts.
    keyMode = "vi";

    # Additional configuration to add to tmux.conf.
    extraConfig = ''
      set-option -ga terminal-overrides ",tmux-256color:RGB"

      # Act like Vim
      # ###########################################################################
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?|.vim-wrapped)(diff)?$'"

      # Move between panes with C-direction
      bind -n C-k run-shell "if $is_vim ; then tmux send-keys C-k ; else tmux select-pane -U; fi"
      bind -n C-j run-shell "if $is_vim ; then tmux send-keys C-j; else tmux select-pane -D; fi"
      bind -n C-h run-shell "if $is_vim ; then tmux send-keys C-h; else tmux select-pane -L; fi"
      bind -n C-l run-shell "if $is_vim ; then tmux send-keys C-l; else tmux select-pane -R; fi"

      # Tmux copy mode as Vim
      bind P paste-buffer
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'

      # Custom mappings
      # ###########################################################################

      # List all sessions by a name
      bind s choose-tree -sZ -O name

      # List all windows by a name
      bind w choose-tree -wZ -O name

      # Maintain the zoom state swiching to last pane
      bind \; last-pane -Z

      # Extract URL from the current pane and open in a popup
      # Note: tmuxPlugins.urlview is not used as it distrupts the workflow
      # by opening a pane below
      bind-key u capture-pane \; \
      save-buffer /tmp/tmux-buffer \; \
      display-popup -E '${pkgs.extract_url}/bin/extract_url /tmp/tmux-buffer'

      # Source config
      bind r source-file ${config.home.homeDirectory}/${config.xdg.configFile."tmux/tmux.conf".target}  \; display-message "Config sourced..."
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'

          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all "${config.home.homeDirectory}/nix-config/users/${config.home.username}/scripts/tmux/post_save.sh $resurrect_dir/last"

          set -g @resurrect-processes 'nvim "-S"'
          set -g @resurrect-processes '~nix-shell "--run'
          set -g @resurrect-processes '"~osmosisd start"'

          set -g @resurrect-save 'S'
          set -g @resurrect-restore 'R'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '1' # minutes
        '';
      }
    ];
  };

  # Enable Git & Git LFS
  programs.git = {
    enable = true;
    lfs.enable = true;
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
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
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
    pinentry.package = pkgs.pinentry-qt;
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

    initContent = ''
       # Options
       # More options: https://zsh.sourceforge.io/Doc/Release/Options.html
       setopt AUTO_PARAM_SLASH
       unsetopt CASE_GLOB

       setopt AUTO_PUSHD
       setopt PUSHD_IGNORE_DUPS
       setopt PUSHD_SILENT

       # History
       # http://zsh.sourceforge.net/Doc/Release/Options.html#History
       setopt append_history          # append to history file
       setopt extended_history        # write the history file in the ':start:elapsed;command' format
       unsetopt hist_beep             # don't beep when attempting to access a missing history entry
       setopt hist_find_no_dups       # don't display a previously found event
       setopt hist_ignore_all_dups    # delete an old recorded event if a new event is a duplicate
       setopt hist_ignore_dups        # don't record an event that was just recorded again
       setopt hist_ignore_space       # don't record an event starting with a space
       setopt hist_no_store           # don't store history commands
       setopt hist_reduce_blanks      # remove superfluous blanks from each command line being added to the history list
       setopt hist_save_no_dups       # don't write a duplicate event to the history file
       setopt hist_verify             # don't execute immediately upon history expansion
       setopt inc_append_history      # write to the history file immediately, not when the shell exits
       setopt share_history           # share history between all sessions

       # Enable extended globbing
       setopt EXTENDED_GLOB

       # Enable Vi mode
       bindkey -v
       bindkey "^?" backward-delete-char # Fix modes N -> I -> I backspace  not working
       bindkey -M viins '^W' backward-kill-word

       export KEYTIMEOUT=1 # timeout for switching between INSERT/NORMAL modes

       # Enable CTRL-P CTRL-N
       bindkey "^P" up-line-or-search
       bindkey "^N" down-line-or-search

      # Open editor with CTRL-X
       open_editor() {
           $EDITOR "$@"
       }

       zle -N open_editor  # Register as a Zsh widget
       bindkey "^X" open_editor  # Bind Ctrl+X

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
      switch-all = "switch-host && switch-home";
    };

    history = {
      # Maximum history events for history file 
      save = 100000;

      # Share command history between sessions.
      share = true;
    };

    # Named directory hash table.
    dirHashes = {
      docs = "$HOME/Documents";
      vids = "$HOME/Videos";
      dl = "$HOME/Downloads";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zpm-zsh/colorize"; }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; tags = [ defer:2 ]; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };

    ## Plugins to source
    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./. + "/zsh";
        file = ".p10k.zsh";
      }
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

{ vim-full, pkgs, ... }:
let
  # Generate" usingtricktux/pomodoro.vim http://gist.github.com/jagajaga/3c7ba009ee6756e12978 
  gofmt = pkgs.vimUtils.buildVimPlugin {
      name = "gofmt";
      version = "2022-08-03";
      src = pkgs.fetchFromGitHub {
        owner = "darrikonn";
        repo = "vim-gofmt";
        rev = "cea5b06b2c2646ced49a64f006be2edb42645dd1";
        sha256 = "BBL65NRDDxJNdOQ/vwknqXyZ5Er4T5hAQXh2FolGPws=";
      };
      meta.homepage = "https://github.com/darrikonn/vim-gofmt/";
    };

  pomodoro = pkgs.vimUtils.buildVimPlugin {
      name = "pomodoro-vim";
      version = "2021-07-10";
      src = pkgs.fetchFromGitHub {
        owner = "tricktux";
        repo = "pomodoro.vim";
        rev = "2b0fec461b84d50aed56709a5b84c7b02d33cc09";
        sha256 = "VFBLvr6rfYHezTIgit6Znp0Pz3D4k3Bw1MGxOxGv/+E=";
      };
      meta.homepage = "https://github.com/tricktux/pomodoro.vim";
    };

  vim-delve = pkgs.vimUtils.buildVimPlugin {
      name = "vim-delve";
      version = "2022-12-13";
      src = pkgs.fetchFromGitHub {
        owner = "sebdah";
        repo = "vim-delve";
        rev = "41d6ad294fb6dd5090f5f938318fc4ed73b6e1ea";
        sha256 = "sha256-wMDTMMvtjkPaWtlV6SWlQ5B7YVsJ4gjPZKPactW8HAE=";
      };
      meta.homepage = "https://github.com/sebdah/vim-delve";
    };

in {

  # Vim dot files
  environment = {
    etc = {
      "vim".source = ../.dotfiles/vim;
    };
  };

  # Vim and required packages
  environment.systemPackages = with pkgs; [
    # Required by fzf
    ripgrep
    
    # Enable syntax highlighting in fzf preview window
    bat
    
    # required by YouCompleteMe, with newer than 3.10 does not work ATM.
    stable.python39

    # required by YouCompleteMe.
    # YouCompleteMe for some reason is not able to find gopls
    stable.gopls

    # Vim
    ((stable.vim_configurable.override {  }).customize{
      name = "vim";
      
      # vimrcFile = ./vim/.vimrc;
      vimrcConfig.customRC = ''
        " Include dotfiles into runtimepath.
        set runtimepath+=/etc/vim

        " Use Vim settings, rather than Vi settings
        set nocompatible

        " Enable loading the indent file for specific file types
        filetype plugin indent on
        
        "###########################################################################
        " Vim system settings
        " PLUGINS SETTINGS HAS DEDICATED SECTION BELOW, DO NOT MIX
        
        " When your .vimrc file is sourced twice, the autocommands will appear twice.
        " To avoid this, put this command in your .vimrc file, before defining autocommands
        autocmd!
        
        " Make sure you put this _before_ the ":syntax enable" command, otherwise the colors will already have been set
        source /etc/vim/plugins/papercolor.vim
        
        " Enable syntax highlighting when terminal supports colors
        if &t_Co > 1
           syntax enable
        endif
        
        " Flash screen instead of beep sound
        set visualbell
        
        " Change how vim represents characters on the screen
        set encoding=utf-8
        
        " Set the encoding of files written
        set fileencoding=utf-8
        
        " Indent by 2 spaces when hitting tab
        set softtabstop=2
        
        " Indent by 4 spaces when auto-indenting
        set shiftwidth=4
        
        " Show existing tab with 4 spaces width
        set tabstop=4
        
        " Open pop up widow instead of opening split window
        set completeopt+=popup
        
        " Enable spell checking
        set spell
        
        " Show @@@ in the last line if it is truncated.
        set display=truncate
        
        set tabpagemax=100
        
        " Set leader key
        nnoremap <SPACE> <Nop>
        let mapleader="\<Space>"
        let maplocalleader="\\"
        
        " Display line numbers
        set number
        
        " Set relative numbers
        set relativenumber

        " Display the current search match position
        set shortmess-=S
        
        " Status line  ---------------------- {{{
        set laststatus=2
        set statusline=
        set statusline +=%1*\ %n\ %*            "buffer number
        set statusline +=%5*%{&ff}%*            "file format
        set statusline +=%3*%y%*                "file type
        set statusline +=%4*\ %<%F%*            "full path
        set statusline +=%2*%m%*                "modified flag
        set statusline +=%1*%=%5l%*             "current line
        set statusline +=%2*/%L%*               "total lines
        set statusline +=%1*%4v\ %*             "virtual column number
        " }}}
        
        " Backspace fix
        set backspace=indent,eol,start
        
        " Display the commands as you type it in Vim
        set showcmd
        
        " Mark the line the cursor is currently in
        set cursorline
        
        " Always show cursor position
        set ruler
        
        " Enable project specific .vimrc
        set exrc
        
        " Keep a backup copy of a file when overwriting it.
        if has("vms")
          set nobackup
        else
          set backup
          set patchmode=.orig
          if has('persistent_undo')
            " Maintain undo history between sessions
        	set undofile
          endif
        endif
        
        " When 'wildmenu' is on, command-line completion operates in an enhanced mode.
        set wildmenu
        
        " Append working directory to the PATH, so we can use find to search project
        " files recursively.
        set path+=$PWD/**
        "
        " While typing a search command, show where the pattern, as it was typed so far, matches.
        set incsearch
        
        " Use 256 colors in terminal.
        if !has("gui_running")
            set t_Co=256
            set term=screen-256color
        endif
        
        " Enable invisible chars.
        set list
        set listchars=tab:▸\ ,eol:¬
        
        " Set cursor shapes based on the mode
        if &term == 'xterm-256color' || &term == 'screen-256color'
            let &t_SI = "\<Esc>[6 q"  " start insert mode, bar
            let &t_EI = "\<Esc>[2 q"  " end insert mode, block
        
        	" Restore cursor shape resuming back to Vim
        	let &t_TI .= "\e[2 q"	  " controls what happens when you exit
        	let &t_TE .= "\e[4 q"	  " controls what happens when you start
        endif
        
        " Yank to system clipboard
        if system('uname -s') == "Darwin\n"
          "OSX
          set clipboard=unnamed 
        else
          "Linux
          set clipboard=unnamedplus
        endif
        
        " If you don't want to turn 'hlsearch' on, but want to highlight all
        " 	matches while searching, you can turn on and off 'hlsearch' with
        " 	autocmd.  Example: >
        augroup vimrc-incsearch-highlight
         autocmd!
         autocmd CmdlineEnter /,\? :set hlsearch
         autocmd CmdlineLeave /,\? :set nohlsearch
        augroup END
        
        " The original meaning of Ctrl-j is 'move [n] lines downward'
        " Turn off it.
        let g:C_Ctrl_j   = 'off'
        let g:C_Ctrl_k   = 'off'
        
        " Tweak escape time from INSERT mode to NORMAL
        " to switch instantly with no delay
        set ttimeout
        set ttimeoutlen=1
        
        " Briefly move cursor to the matching pair.
        set showmatch
        
        " Do not start search from the beginning.
        set nowrapscan
        
        set cpo-=<
        
        " Look for a tags file in the directory of the current file, then upward until
        " / and in the working directory, then upward until $HOME.
        set tags=./tags;,tags;

        " Load custom functions
        source /etc/vim/functions.vim

        " Load mappings from a separate file.
        source /etc/vim/mappings.vim

        
        " Plugin(s) settings  ---------------------- {{{
        " This section is intentionally moved after initial settings defined above 
        " because some of the plugins might alter those.
        " TODO: pomodoro
        source /etc/vim/plugins/committia.vim
        source /etc/vim/plugins/ultisnips.vim
        source /etc/vim/plugins/vimhardtime.vim
        source /etc/vim/plugins/tmux.vim
        source /etc/vim/plugins/fzf.vim
        source /etc/vim/plugins/ycm.vim
        source /etc/vim/plugins/netrw.vim
        source /etc/vim/plugins/vifm.vim
        source /etc/vim/plugins/delve.vim
        " source /etc/vim/plugins/pomodoro.vim
        " }}}
        
        " Add optional packages. ------------------{{{
        
        " This plugin displays a manual page in a nice way.  
        " See |find-manpage|.
        runtime ftplugin/man.vim
        
        " The matchit plugin makes the % command work better, but it is not backwards
        " compatible.
        " The ! means the package won't be loaded right away but when plugins are
        " loaded during initialization.
        if has('syntax') && has('eval')
          packadd! matchit
        endif 
        " }}}
 
        " Cursor line settings  ---------------------- {{{
        " Display cursor line only in a active window.
        " https://codeyarns.com/tech/2013-02-07-how-to-show-cursorline-only-in-active-window-of-vim.html#gsc.tab=0
        augroup CursorLineOnlyInActiveWindow 
        	autocmd!
        	autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
        	autocmd WinLeave * setlocal nocursorline
        augroup end
        " }}}
        
        " Return to last edit position when opening files (You want this!)
        autocmd BufReadPost *
             \ if line("'\"") > 0 && line("'\"") <= line("$") |
             \   exe "normal! g`\"" |
             \ endif
        
        " Quite a few people accidentally type "q:" instead of ":q" and get confused
        " by the command line window.  Give a hint about how to get out.
        " If you don't like this you can put this in your vimrc:
        " ":augroup vimHints | exe 'au!' | augroup END"
        augroup vimHints
          autocmd!
          autocmd CmdwinEnter *
            \ echohl Todo | 
            \ echo 'You discovered the command-line window! You can close it with ":q".' |
            \ echohl None
        augroup END
        
        " Operator-pending mappings ---------------------- {{{
        onoremap in( :<c-u>normal! f(vi(<cr>
        onoremap il( :<c-u>normal! F)vi(<cr>
        
        onoremap in{ :<c-u>normal! ?{vi{<cr>
        
        augroup markdown_operators
          autocmd!
        
          autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^==\\\|--\\+$\r:nohlsearch\rkvg_"<cr>
        augroup END
        " }}}
        
        "###########################################################################
        " General Autocmd's
        "
        " NOTE: File specific cmd's goes into: ~/.vim/ftplugin/{filetype}_whatever.vim
        "###########################################################################
        "###########################################################################
        
        " Abbreviations ---------------------- {{{
        iabbrev @@ hi@deividaspetraitis.lt
        iabbrev ccopy Copyright 2013 Deividas Petraitis, all rights reserved.
        iabbrev ssig -- <cr>Deividas Petraitis<cr>hi@deividaspetraitis.lt
        " }}}
        
        " Convenient command to see the difference between the current buffer and the
        " file it was loaded from, thus the changes you made.
        " Only define it when not defined already.
        " Revert with: ":delcommand DiffOrig".
        if !exists(":DiffOrig")
          command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        		  \ | wincmd p | diffthis
        endif
      '';

      # List of supported plugin names can be found: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/vim-plugin-names
      vimrcConfig.packages.myplugins = with pkgs; {
         # loaded on launch
         start = [ 
           # Vim Hardtime helps you break that annoying habit vimmers have of scrolling up and down the page using jjjjj and kkkkk but without compromising the rest of our vim experience.
           vimPlugins.vim-hardtime

           # YouCompleteMe: a code-completion engine for Vim
           stable.vimPlugins.YouCompleteMe
           
           # UltiSnips is the ultimate solution for snippets in Vim. It has many features, speed being one of them. Track the engine.
           vimPlugins.ultisnips
           
           # Snippets are separated from the engine. Add this if you want them:
           vimPlugins.vim-snippets
           
           # Minimal Vim Go formatter plugin
           # The contents of this plugin are pure copy-paste from the awesome vim-go repo.
           gofmt
           
           # Light & Dark color schemes for terminal and GUI Vim awesome editor
           # Inspired by Google's Material Design. Improve code readability! Great for presentation!
           vimPlugins.papercolor-theme
           
           # Repeat.vim remaps . in a way that plugins can tap into it.
           vimPlugins.vim-repeat
           
           # The plugin provides mappings to easily delete, change and add such surroundings in pairs.
           vimPlugins.vim-surround
           
           # A plugin to place, toggle and display marks
           vimPlugins.vim-signature
           
           # Peekaboo will show you the contents of the registers on the sidebar when you hit " or @ in normal mode or <CTRL-R> in insert mode
           vimPlugins.vim-peekaboo
           
           # Tree-sitter is a parser generator tool and an incremental parsing library.
           # It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited. 
           # completion-treesitter

           # Things you can do with fzf and Vim.
           vimPlugins.fzf-vim

           # Focus on the task and temporarily disable the distraction elements in Neovim
           vimPlugins.goyo-vim

           # Dim all lines except the current line when turned on.
           vimPlugins.limelight-vim

           # More Pleasant Editing on Commit Message
           vimPlugins.committia-vim

           # Fugitive is the premier Vim plugin for Git
           vimPlugins.vim-fugitive

           # If fugitive.vim is the Git, rhubarb.vim is the Hub
           vimPlugins.vim-rhubarb

           # Pomodoro plugin
           # TODO: fails to install
           # pomodoro

           # Commenting plugin
           vimPlugins.vim-commentary

           # The undo history visualizer
           vimPlugins.undotree

           # Support for writing Nix expressions in vim
           vimPlugins.vim-nix

           # Allow Vim to integrate with the Wayland clipboard
           vimPlugins.vim-wayland-clipboard

           # Vim sessions management
           vimPlugins.vim-obsession

           # Vim plugin that allows use of vifm as a file picker
           vimPlugins.vifm-vim

           # Use (neo)vim terminal in the floating/popup window.
           vimPlugins.vim-floaterm

           # GitHub Copilot for Vim and Neovim
           vimPlugins.copilot-vim

           # A plugin making easily interact with tmux from Vim
           vimPlugins.vimux

           # Neovim and Vim plugin for debugging Go applications using Delve.
           vim-delve
         ];

         # manually loadable by calling `:packadd $plugin-name`
         # however, if a Vim plugin has a dependency that is not explicitly listed in
         # opt that dependency will always be added to start to avoid confusion.
         opt = [ ];
      };
    }
  )];
}

(setq inihibit-startup-message t)

(scroll-bar-mode -1)    ; Disable visible scrollbar
(tool-bar-mode -1)      ; Disable the toolbar
(tooltip-mode -1)       ; Disable tooltips
;(set-fringe-mode 10) ; Give some breathing room

(menu-bar-mode -1)      ; Disable the menu bar
(setq visible-bell t)   ; Set up the visible bell

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 210) ; Set the default font and size

(load-theme 'tango-dark) ; Load the tango-dark theme, don't ask me what "'" means
(column-number-mode)                       ; Display column
(setq display-line-numbers-type 'relative) ; Display relative line number
(global-display-line-numbers-mode +1)      ; Diplay line numbers

(global-set-key (kbd "M-n") #'scroll-up-line)     ;; scroll down 1 line
(global-set-key (kbd "M-p") #'scroll-down-line)   ;; scroll up 1 line

;; Initialize package sources
(require 'package) ; Require the package module to manage packages
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/"))) ; Set the package archives to use MELPA, Org, and ELPA

(package-initialize) ; Initialize the package system
(unless package-archive-contents ; Unless archive contents are already downloaded
  (package-refresh-contents)) ; Refresh the package contents if they haven't been downloaded yet

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package) ; If use-package is not installed
  (package-install 'use-package)) ; Install use-package

(require 'use-package)                 ; Require use-package for managing packages
(setq use-package-always-ensure t)     ; Always ensure that packages are installed


; A generic completion mechanism for Emacs
; https://elpa.gnu.org/packages/doc/ivy.html
(use-package ivy
  :ensure t ; install the package automagically if missing
  :config   ; run the package after it is loaded
  (ivy-mode 1))

; A collection of Ivy-enhanced versions of common Emacs commands
; https://elpa.gnu.org/packages/counsel.html
(use-package counsel
  :ensure t   ; install the package automatically if missing 
  :after ivy  ; only afer ivy package
  :bind (("M-x" . counsel-M-x)             ; run counsel-M-x on M-x
	 ("C-x b" . counsel-ibuffer)       ; run counsel-ibuffer on C-x b
	 ("C-x C-f" . counsel-find-file))  ; ... you get an idea :) ...
  :config     ; and run it once it is loaded
  (counsel-mode 1))

; ivy-rich enhances ivy and counsel by providing
; decription documentation for commands including
; keybinds
; https://github.com/Yevgnen/ivy-rich
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

; Emacs has similar concept of jump list as vim
; so you can jump back with C-u C-SPC however it
; lacks capability of jumping backwars.
; Better jumper fills that gap.
; https://github.com/gilbertw1/better-jumper
(use-package better-jumper
  :ensure t
  :init ; init happens before a package is loaded
  (better-jumper-mode 1)
  :bind (("M-o" . better-jumper-jump-backward)
         ("M-i" . better-jumper-jump-forward)))

; which-key is a minor mode for Emacs that displays
; the key bindings following your currently entered
; incomplete command (a prefix) in a popup.
; https://github.com/justbur/emacs-which-key
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 1)) ; delay delays the popup

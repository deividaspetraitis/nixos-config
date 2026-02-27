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

(save-place-mode 1)   ;; Automatically save place for each file, so we can do like in Vim `0

(windmove-default-keybindings 'meta) ;; Jump across windows with Alt + arrow keys

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

;; Minibuffer completion UI (replaces ivy)
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; Consult: enhanced commands (replaces most counsel/swiper use-cases)
(use-package consult
  :ensure t
  :bind (("M-x" . consult-mode-command)     ;; filtered, contextual subset command dispatcher
	 ("M-X" . execute-extended-command) ;; global command dispatcher
         ("C-x b" . consult-buffer)         ;; buffer switch
         ("C-x C-f" . find-file)            ;; find-file for browsing 
         ("C-c s" . consult-ripgrep)))      ;; project search (rg)

;; Rich annotations (replaces ivy-rich)
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

;; Orderless allows better matching when searching
;; for files in C-x C-f
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Preserve minibuffer history
(use-package savehist
  :init
  (savehist-mode 1))

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

;; Install org mode
(use-package org
  :config
  (setq org-agenda-files
        '("~/SynologyDrive/OrgFiles/Tasks.org"))
  ;; LaTeX rendering by default looks not reader friendly
  ;; so we switch to SVG rendering, match LaTeX backround to
  ;; tmee and finally scale a bit to make font a bit bigger
  (setq org-preview-latex-default-process 'dvisvgm) ; Switch to SVG rendering for LaTeX
  (setq org-format-latex-options
        (plist-put org-format-latex-options :background "Transparent")); Match LaTeX backround to theme
   (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.8)) ; Increase scaling for LaTeX
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
	 ("C-c l s" . org-store-link)
         ("C-c l n" . org-next-link)
         ("C-c l p" . org-previous-link)
         ("C-c l o" . org-open-at-point)
         ("C-c l b" . org-mark-ring-goto)))

(defvar-local my/org-readerish-enabled nil
  "Whether my reader-ish Org visuals are enabled in this buffer.")

(defun my/toggle-org-readerish ()
  "Toggle a clean 'reader-ish' view for Org buffers."
  (interactive)
  (setq my/org-readerish-enabled (not my/org-readerish-enabled))

  ;; Toggle org-modern visuals
  (org-modern-mode (if my/org-readerish-enabled 1 -1))

  ;; Toggle emphasis markers (buffer-local)
  (setq-local org-hide-emphasis-markers my/org-readerish-enabled)

  ;; Toggle link display style (buffer-local)
  ;; t  => show descriptive links
  ;; nil => show raw [[...]] links
  (setq-local org-link-descriptive my/org-readerish-enabled)

  ;; Toggle LaTeX preview overlays
  (if my/org-readerish-enabled
      (org-latex-preview)      ;; create previews
    (org-latex-preview '(4)))  ;; C-u => clear/remove previews
  
  ;; Refresh display
  (org-font-lock-flush)
  (org-font-lock-ensure))

(global-set-key (kbd "C-c e") #'my/toggle-org-readerish)

;; A modern style for your Org buffers using font locking and text properties
;; https://github.com/minad/org-modern/tree/main?tab=readme-ov-file
(use-package org-modern
  :ensure t ;; ensure the package automatically if missing
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :config
  ;; Org styling, hide markup etc.
  (setq org-hide-emphasis-markers t)
  (setq org-pretty-entities t)
  (setq org-agenda-tags-column 0)
  (setq org-ellipsis "…"))

;; A plain-text personal knowledge management system
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/SynologyDrive/org-roam/")) ;; Set a location for storing Org-roam files
  :config
  (org-roam-db-autosync-mode)       ;; ensure Org-roam is available at startup
  (setq org-roam-capture-templates  ;; org-roam capture templates
      '(("f" "Fleeting" plain
         "%?"
         :if-new (file+head "Fleeting/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+date: %U\n#+filetags: :fleeting:\n\n")
         :unnarrowed t)

        ("l" "Literature" plain
         "%?"
         :if-new (file+head "Literature/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+date: %U\n#+filetags: :literature:\n\n#+author:\n#+source:\n\n")
         :unnarrowed t)

        ("p" "Permanent" plain
         "%?"
         :if-new (file+head "Permanent/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+date: %U\n#+filetags: :permanent:\n\n")
         :unnarrowed t)))
  :bind (("C-c n f" . org-roam-node-find)      ;; find/open node    
        ("C-c n i" . org-roam-node-insert)    ;; insert link to node
        ("C-c n c" . org-roam-capture)        ;; capture/create node
        ("C-c n g" . org-roam-graph)          ;; graph (if you use it)
        ("C-c n b" . org-roam-buffer-toggle))) ;; backlinks buffer

;; Backup files and auto save files polutes working
;; directory.
;; Also keeping multiple copies of same file may slow
;; down org-roam.
(setq backup-directory-alist ;; Put backup files in ~/.emacs.d/backups
      `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
(setq auto-save-file-name-transforms ;; Put auto-save files in ~/.emacs.d/auto-saves
      `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t)))
(make-directory (expand-file-name "backups/" user-emacs-directory) t) ;; Create the directories if they don't exist
(make-directory (expand-file-name "auto-saves/" user-emacs-directory) t)

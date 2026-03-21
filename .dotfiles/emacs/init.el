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

;; Enable debug errors
(setq debug-on-error t)
(setq use-package-verbose t)

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

;; Org Tempo expands snippets to structures
;; See: https://orgmode.org/manual/Structure-Templates.html
;; A list specifies language specific shortucts, for exampe <py <TAB>
;; for exapanding Python source code block
(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("js" . "src javascript"))
(add-to-list 'org-structure-template-alist '("rs" . "src rust"))

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

(use-package consult-notes
  :commands (consult-notes
             consult-notes-search-in-all-notes
             ;; if using org-roam 
             consult-notes-org-roam-find-node
             consult-notes-org-roam-find-node-relation)
  :config
   ;; Set notes dir(s), see below
  (setq consult-notes-file-dir-sources
      '(("Org"             ?o "~/SynologyDrive/org/")
        ("Org Refile"      ?r "~/SynologyDrive/org/roam/")))
  ;; Set org-roam integration, denote integration, or org-heading integration e.g.:
  ;;(setq consult-notes-org-headings-files '("~/path/to/file1.org"
  ;;                                         "~/path/to/file2.org"))
  ;; (consult-notes-org-headings-mode)
  (when (locate-library "denote")
    (consult-notes-denote-mode))
  ;; search only for text files in denote dir
  (setq consult-notes-denote-files-function (lambda () (denote-directory-files nil t t))))

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

;; Allow to edit language specific source code blocks with C-c '
(use-package yaml-mode)
(use-package rust-mode)
(use-package go-mode)

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

;; Helper function creating note files creating a slug
;; from title to be used as a file name
(defun my/org-create-note (dir)
  (let* ((title (read-string "Title: "))
         (slug (let ((s (downcase title)))
                 (setq s (replace-regexp-in-string "[[:space:]]+" "-" s))
                 (setq s (replace-regexp-in-string "[^a-z0-9-]" "" s))
                 (setq s (replace-regexp-in-string "-+" "-" s))
                 (replace-regexp-in-string "^-\\|-$" "" s)))
         (file (expand-file-name (format "%s.org" slug) dir)))
    (setq org-capture-last-title title)
    file))

;; Required by jupyter
(use-package zmq
  :ensure t
  :config
  (require 'zmq)
  (zmq-load))

;; Emacs jupyter is used for plotting graphs
(use-package jupyter
  :vc (:url "git@github.com:emacs-jupyter/jupyter.git"
       :rev "2059d79")
;; (use-package jupyter
;;  :ensure t
  :after (org zmq)
  :config
  (require 'zmq)
  (require 'ob-jupyter)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (julia . t)
     (jupyter . t))))

;; Install org mode
(use-package org
  :hook ((org-mode . visual-line-mode)) ;; Wrap lines
        ;; (org-mode . org-indent-mode)) ;; Align text with headlines
  :config
  (setq org-directory "~/SynologyDrive/org")
  (setq org-agenda-files 
      '("~/SynologyDrive/org/habits.org"
        "~/SynologyDrive/org/inbox.org"
	"~/SynologyDrive/org/personal.org"
	"~/SynologyDrive/org/refinement.org"
	"~/SynologyDrive/org/inbox.org"
	"~/SynologyDrive/org/math.org"
        "~/SynologyDrive/org/infra.org"))
  ;;(setq org-src-preserve-indentation t)
  ;;(setq org-edit-src-content-indentation 0)
  ;;(setq org-adapt-indentation nil)

  ;; LaTeX rendering by default looks less reader-friendly,
  ;; so switch to SVG, match the background to the theme,
  ;; and scale it up a bit.
  (setq org-preview-latex-default-process 'dvisvgm)                    ;; Switch to SVG rendering for LaTeX
  (setf (plist-get org-format-latex-options :background) "Transparent" ;; Match LaTeX backround to theme
        (plist-get org-format-latex-options :scale) 1.8)              ;; Increase scaling for LaTeX

  (setq org-refile-targets
	'(("~/SynologyDrive/org/inbox.org" :maxlevel . 1)
          ("~/SynologyDrive/org/personal.org" :maxlevel . 1)
	  ("~/SynologyDrive/org/math.org" :maxlevel . 1)
	  ("~/SynologyDrive/org/infra.org" :maxlevel . 1)
	  ("~/SynologyDrive/org/refinement.org" :maxlevel . 1)
         ("~SynologyDrive/org/tasks.org" :maxlevel . 1)))
  
  ;; Capture templates
  (setq org-capture-templates
      '(("i" "Inbox task"
         entry
         (file+headline "~/SynologyDrive/org/inbox.org" "Tasks")
         "* TODO %?\nCREATED: %U\n")

        ("t" "Regular Task"
         plain
         (file (lambda () (my/org-create-note "~/SynologyDrive/org/tasks/")))
         "* TODO %(identity org-capture-last-title)\n#+created: %U\n:PROPERTIES:\n:SPRINT: %^{Sprint|}\n:EFFORT: %^{Effort|1:00}\n:END:\n\n** Context\n\n** Log\n\n")

	("p" "Project"
         plain
         (file (lambda () (my/org-create-note "~/SynologyDrive/org/")))
	 "* TODO %^{Project name} :project:\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n** Goal\n%?\n\n** TODO First step\n\n
** Notes\n")))

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
  (org-roam-directory (file-truename "~/SynologyDrive/org/roam/")) ;; Set a location for storing Org-roam files
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
  ;; Along the note template it quite useful to see tags providing
  ;; more context as same concept may fall/span under multiple areas
  (setq org-roam-node-display-template
      (concat "${title:*} "
              (propertize "${tags:20}" 'face 'org-tag)))
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

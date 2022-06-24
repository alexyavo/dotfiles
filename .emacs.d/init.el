;; not sure what the optimal value is
;;(setq gc-cons-threshold 100000000)

(if (eq system-type 'windows-nt)
    (setq my/homedir "C:\\")
  (setq my/homedir "~"))

(cond ((eq system-type 'windows-nt)
       (progn
         ))

      ((eq system-type 'gnu/linux)
       (progn
         ))

      ((eq system-type 'darwin)
       (progn
         (add-to-list 'exec-path "/usr/local/bin")
         (setq ispell-program-name "/usr/local/bin/aspell") ;; brew install aspell

         (setq mac-command-key-is-meta t)
         (setq mac-option-key-is-meta nil)

         (setq mac-option-modifier 'command)
         (setq mac-command-modifier 'meta)
         (setq mac-control-modifier 'control)

         ;; https://colinxy.github.io/software-installation/2016/09/24/emacs25-easypg-issue.html
         (setq epa-pinentry-mode 'loopback)))

      (t (error "UNKNOWN system-type")))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("melpa"  . "https://melpa.org/packages/")
                         ("org"    . "http://orgmode.org/elpa/")))

;; make sure to have downloaded archive description.
;; Or use package-archive-contents as suggested by Nicolas Dudebout
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(when (not (package-installed-p 'use-package))
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(use-package utils :load-path "mycode")

;; ================================================================================
;; global
;; ================================================================================

(global-set-key (kbd "C-c k") 'delete-frame)
(global-set-key (kbd "C-c n") 'make-frame)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-c f") 'find-grep)
(global-set-key (kbd "M-,") 'pop-global-mark)
(global-set-key [f1] 'whitespace-mode)
(global-set-key [f5] '(lambda () (interactive) (revert-buffer t t t)))

;; no idea what
(put 'upcase-region 'disabled nil)

;; ================================================================================
;; UI
;; ================================================================================
(use-package dracula-theme :ensure t :config (load-theme 'dracula t))
;;(use-package darktooth-theme :ensure t :config (load-theme 'darktooth t))
;;(use-package color-theme-sanityinc-tomorrow :ensure t :config (load-theme 'sanityinc-tomorrow-night t))

;; (if (not (is-running-in-graphic-ui))
;;     (set-face-attribute 'default nil :font "Source Code Pro-13"))

(setq create-lockfiles nil) ;; dunno if it's a good idea

;; caret / cursor
(set-default 'cursor-type 'box)

;; make pop-to-buffer not resize the window
(setq even-window-heights nil)

;; on each save, remove trailing spaces from each line
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; highlight parenthessis
(show-paren-mode 1)

(if (is-running-in-graphic-ui)
    (progn
      (scroll-bar-mode -1)
      (fringe-mode 1)
      ;; set default window size
      (add-to-list 'default-frame-alist '(height . 70))
      (add-to-list 'default-frame-alist '(width . 120))
      (setq x-select-enable-clipboard t)  ;; enable copy-paste from X windows - does not work for terminal
      ))

(setq-default indent-tabs-mode nil) ;; by default, indent with spaces only (no tabs)
(setq default-tab-width 2)

;; no splash screen (welcome screen)
(setq inhibit-splash-screen t)

(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(setq-default indicate-buffer-boundaries 'left)
(setq default-indicate-empty-lines t)
(blink-cursor-mode -1)
(setq visible-cursor nil)
(column-number-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq-default fill-column 100)

;; Reduce the number of times the bell rings
;; Turn off the bell for the listed functions.
(setq ring-bell-function
      (lambda ()
        (unless (memq this-command
                      '(isearch-abort
                        abort-recursive-edit
                        exit-minibuffer
                        keyboard-quit
                        previous-line
                        next-line
                        scroll-down
                        scroll-up
                        cua-scroll-down
                        cua-scroll-up))
          (ding))))

(setq visible-bell t)

;; ================================================================================
;; Backup files
;; ================================================================================
(defvar my/backup-dir (concat user-emacs-directory "backups"))
(if (not (file-exists-p my/backup-dir))
    (make-directory my/backup-dir t))

;; Put all backups in one directory
(setq backup-directory-alist `((".*" . ,my/backup-dir)))

;; Put all auto save files in systems temporary files directory
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Various params for backup files
;; (setq make-backup-files t               ; backup of a file the first time it is saved.
;;       backup-by-copying t               ; don't clobber symlinks
;;       version-control t                 ; version numbers for backup files
;;       delete-old-versions t             ; delete excess backup files silently
;;       delete-by-moving-to-trash nil
;;       kept-old-versions 3               ; oldest versions to keep when a new numbered backup is made (default: 2)
;;       kept-new-versions 3               ; newest versions to keep when a new numbered backup is made (default: 2)
;;       auto-save-default t               ; auto-save every buffer that visits a file
;;       auto-save-timeout 30              ; number of seconds idle time before auto-save (default: 30)
;;       auto-save-interval 300            ; number of keystrokes between auto-saves (default: 300)
;;       )

;; ================================================================================
;; packages
;; ================================================================================

;; Makes sure PATH is the same as in the shell
(use-package exec-path-from-shell
  :ensure t
  :config (when (memq window-system '(mac ns x))
            (exec-path-from-shell-initialize)))

(use-package dired
  :config (progn
            (setq insert-directory-program "gls" dired-use-ls-dired t)
            (setq dired-recursive-deletes 'always)
            (setq dired-recursive-copies  'always)

            ;; Enable copying between two panes. press C to copy (S-c)
            ;; To copy multiple files: mark every file you want to copy with m, then
            ;; press C (S-c) to copy them all.
            (setq dired-dwim-target t)

            ;; Set this variable to non-nil, Dired will try to guess a default
            ;; target directory. This means: if there is a dired buffer
            ;; displayed in the next window, use its current subdir, instead
            ;; of the current subdir of this dired buffer. The target is used
            ;; in the prompt for file copy, rename etc.
            (setq dired-dwim-target t)

            ;; Dired listing switches
            ;;  -a : Do not ignore entries starting with .
            ;;  -l : Use long listing format.
            ;;  -G : Do not print group names like 'users'
            ;;  -h : Human-readable sizes like 1K, 234M, ..
            ;;  -v : Do natural sort .. so the file names starting with . will show up first.
            ;;  -F : Classify filenames by appending '*' to executables,
            ;;       '/' to directories, etc.
            (setq dired-listing-switches "-alkh --group-directories-first"))
  :bind (:map dired-mode-map
              ("s" . dired-sort)))

(use-package sensitive-mode
  :load-path "mycode"
  :config (setq auto-mode-alist (append '(("\\.\\(priv\\|gpg\\)$" . sensitive-mode)) auto-mode-alist)))

(use-package antlr-mode
  :mode "\\.g4\\'")

(use-package display-line-numbers
  :ensure t
  :config
  ;;  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (global-display-line-numbers-mode)
  ;; TODO not sure this is the best way to do this but it doesn't work with a simple setq here
  ;;      not sure if the setq even applies globally or per buffer... ?
  (add-hook 'display-line-numbers-mode-hook (lambda () (setq display-line-numbers 'relative))))

(use-package default-text-scale
  :ensure t
  :config (default-text-scale-mode))

(use-package company
  :ensure t
  :hook (scala-mode . company-mode)
  :config (progn
            (global-company-mode)
            (setq company-dabbrev-downcase 0)
            (setq company-idle-delay 0.25)
            (setq lsp-completion-provider :capf))
  :bind (:map company-active-map
              ("M-/" . company-complete)))

(use-package company-quickhelp :ensure t :if window-system :init (company-quickhelp-mode t))

(use-package ace-window
  :ensure t
  :config (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind (("C-x o" . ace-window)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c"     . 'mc/edit-lines)
         ;; ("C-c >"           . 'mc/mark-next-like-this)
         ;; ("C-c <"           . 'mc/mark-previous-like-this)
         ("C->"           . 'mc/mark-next-like-this)
         ("C-<"           . 'mc/mark-previous-like-this)
         ("C-c C-<"         . 'mc/mark-all-like-this)
         ("C-S-<mouse-1>"   . 'mc/add-cursor-on-click)))

(use-package neotree
  :ensure t
  :config (progn
            (setq neo-window-fixed-size nil)
            (setq neo-smart-open t)
            (setq neo-theme (if (is-running-in-graphic-ui) 'icons 'arrow)))
  :bind (("<f8>" . 'neotree-toggle)
         :map neotree-mode-map
         ("S" . 'neotree-stretch-toggle)))

(use-package highlight-symbol
  :ensure t
  :bind (("C-c h" . 'highlight-symbol)))

(use-package paredit
  :ensure t
  :config (progn
            (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
            (add-hook 'lisp-mode-hook #'paredit-mode)
            (add-hook 'slime-repl-mode-hook #'paredit-mode)))

(use-package json-mode
  :ensure t
  :config (add-hook 'json-mode-hook (lambda ()
                                      (make-local-variable 'js-indent-level)
                                      (setq js-indent-level 2))))

(use-package json-reformat
  :ensure t
  :config (progn
            (setq json-reformat:indent-width 2)
            (global-set-key (kbd "C-c j f") 'json-reformat-region)))

(use-package helm
  :ensure t
  :config (progn
            (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
                  helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
                  helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
                  helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
                  helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
                  helm-ff-file-name-history-use-recentf t
                  helm-buffer-max-len                   nil)
            (helm-mode t))
  :bind (("M-x"     . 'helm-M-x)
         ("M-y"     . 'helm-show-kill-ring)
         ("C-x b"   . 'helm-mini)
         ("C-x C-f" . 'helm-find-files)))

(use-package helm-swoop :ensure t :bind (("M-i" . 'helm-swoop)))
(use-package helm-ag :ensure t :bind (("C-S-f" . 'helm-ag-project-root)))

(use-package projectile
  :ensure t
  :config (progn
            (setq projectile-completion-system 'helm
                  projectile-switch-project-action 'projectile-find-file)
            (use-package helm-projectile :ensure t :config (helm-projectile-on))
            (projectile-global-mode))
  :bind (("C-c p" . projectile-command-map)))

(use-package org
  :ensure t
  :config (progn
            (setq org-export-htmlize-output-type 'css
                  org-src-fontify-natively t
                  org-src-tab-acts-natively t
                  org-confirm-babel-evaluate nil
                  org-edit-src-content-indentation 0
                  org-tags-column -100)

            (org-babel-do-load-languages
             'org-babel-load-languages
             '((shell  . t)
               (python . t)
               (C      . t))))
  :hook (org-mode . turn-on-auto-fill))

(use-package org-capture
  :config (progn
            (setq org-capture-templates
                  `(("p" "personal")
                    ("pj" "journal" entry (file+olp+datetree (join-dirs my/homedir "notes" "journal.org")) "* %?")

                    ("pp" "project")
                    ("pp1" "example" entry (file "/path/to/example/journal.org") "* %?")))

            (defun org/add-tags-in-capture()
              (interactive)
              "Insert tags in a capture window without losing the point"
              (save-excursion
                (org-back-to-heading)
                (org-set-tags)))

            (use-package org-expiry
              :load-path "mycode"
              :config (progn
                        (setq org-expiry-created-property-name "CREATED"
                              org-expiry-inactive-timestamps t)

                        (defun org/insert-created-timestamp()
                          "Insert a CREATED property using org-expiry.el for TODO entries"
                          (org-expiry-insert-created)
                          (org-back-to-heading)
                          (org-end-of-line))

                        (defadvice org-insert-todo-heading (after activate)
                          "Insert a CREATED property using org-expiry.el for TODO entries"
                          (org/insert-created-timestamp))
                        (ad-activate 'org-insert-todo-heading)

                        (defadvice org-capture (after activate)
                          (org/insert-created-timestamp))
                        (ad-activate 'org-capture))))

  :bind (("<f12>"   . 'org-capture-goto-last-stored)
         ("<f10>"   . 'org-capture)
         ("C-c C-t" . org/add-tags-in-capture)))

(use-package slime
  :ensure t
  :config (progn
            (setq inferior-lisp-program "sbcl")
            (slime-setup '(slime-fancy
                           slime-autodoc
                           slime-asdf
                           slime-banner))))

(use-package poetry :ensure t
  :hook (python-mode . poetry-tracking-mode))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp-deferred))))  ; or lsp-deferred

(use-package server :config (unless (server-running-p) (server-start)))
(use-package ace-jump-mode :ensure t :bind (("C-c a" . ace-jump-mode)))

(use-package lsp-mode
  :ensure t
  :hook (scala-mode . lsp)
        (python-mode . lsp-deferred)
        (lsp-mode . lsp-lens-mode)
  :config (setq lsp-prefer-flymake nil))

(use-package evil :ensure t
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-default-state 'normal) ;; 'emacs
  :config (evil-mode t))

(unless (is-running-in-graphic-ui)
  (use-package evil-terminal-cursor-changer :ensure t
    :init
    (setq evil-motion-state-cursor 'box)  ; █
    (setq evil-visual-state-cursor 'box)  ; █
    (setq evil-normal-state-cursor 'box)  ; █
    (setq evil-insert-state-cursor 'bar)  ; ⎸
    (setq evil-emacs-state-cursor  'hbar) ; _
    :config (evil-terminal-cursor-changer-activate)))

(use-package lsp-metals :ensure t)

(use-package markdown-mode
  :ensure t
  ;; TODO
;;   :config (setq markdown-fontify-code-block-natively t)
  )

(use-package magit :ensure t)
(use-package figlet              :ensure t)
(use-package iedit               :ensure t)
(use-package scala-mode          :ensure t)
(use-package docker              :ensure t)
(use-package dockerfile-mode     :ensure t)
(use-package docker-compose-mode :ensure t)
(use-package groovy-mode         :ensure t)
(use-package terraform-mode      :ensure t)
(use-package yaml-mode           :ensure t)
(use-package protobuf-mode       :ensure t)
(use-package lua-mode            :ensure t)
(use-package all-the-icons       :ensure t)
(use-package all-the-icons-dired :ensure t)
(use-package go-mode             :ensure t)
(use-package rust-mode           :ensure t)
(use-package clojure-mode        :ensure t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("f302eb9c73ead648aecdc1236952b1ceb02a3e7fcd064073fb391c840ef84bca" "9f9fc38446c384a4e909b7220d15bf0c152849ef42f5b1b97356448612c77953" "a9a67b318b7417adbedaab02f05fa679973e9718d9d26075c6235b1f0db703c8" "d7ee1fdb09a671a968b2a751746e5b3f5f26ac1fd475d95d094ee1e4ce446d58" "d14f3df28603e9517eb8fb7518b662d653b25b26e83bd8e129acea042b774298" "6b5c518d1c250a8ce17463b7e435e9e20faa84f3f7defba8b579d4f5925f60c1" "a0be7a38e2de974d1598cf247f607d5c1841dbcef1ccd97cded8bea95a7c7639" "e8df30cd7fb42e56a4efc585540a2e63b0c6eeb9f4dc053373e05d774332fc13" "4b0e826f58b39e2ce2829fab8ca999bcdc076dec35187bf4e9a4b938cb5771dc" "850bb46cc41d8a28669f78b98db04a46053eca663db71a001b40288a9b36796c" "6b1abd26f3e38be1823bd151a96117b288062c6cde5253823539c6926c3bb178" "1704976a1797342a1b4ea7a75bdbb3be1569f4619134341bd5a4c1cfb16abad4" "26e07f80888647204145085c4fed78e0e6652901b62a25de2b8372d71de9c0a1" "97db542a8a1731ef44b60bc97406c1eb7ed4528b0d7296997cbb53969df852d6" "7a7b1d475b42c1a0b61f3b1d1225dd249ffa1abb1b7f726aec59ac7ca3bf4dae" "d2e0c53dbc47b35815315fae5f352afd2c56fa8e69752090990563200daae434" "b7e460a67bcb6cac0a6aadfdc99bdf8bbfca1393da535d4e8945df0648fa95fb" "7661b762556018a44a29477b84757994d8386d6edee909409fabe0631952dad9" "83e0376b5df8d6a3fbdfffb9fb0e8cf41a11799d9471293a810deb7586c131e6" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "43f03c7bf52ec64cdf9f2c5956852be18c69b41c38ab5525d0bedfbd73619b6a" "716f0a8a9370912d9e6659948c2cb139c164b57ef5fda0f337f0f77d47fe9073" "824d07981667fd7d63488756b6d6a4036bae972d26337babf7b56df6e42f2bcd" default)))
 '(package-selected-packages
   (quote
    (evil-terminal-cursor-changer poetry evil lsp-metals lsp-pyright nix-mode edit-indirect arduino-mode smooth-scroll darktooth-theme gruvbox-theme doom-themes color-theme-sanityinc-tomorrow-colors color-theme-sanityinc-tomorrow badger-theme melancholy-theme all-the-icons-dired helm-projectile clojure-mode go-mode all-the-icons lua-mode protobuf-mode terraform-mode groovy-mode docker-compose-mode dockerfile-mode docker scala-mode markdown-mode iedit figlet magit ace-jump-mode slime projectile helm-ag helm-swoop helm json-mode paredit highlight-symbol neotree multiple-cursors ace-window company-quickhelp company default-text-scale exec-path-from-shell dracula-theme use-package)))
 '(pos-tip-background-color "#36473A")
 '(pos-tip-foreground-color "#FFFFC8")
 '(safe-local-variable-values
   (quote
    ((flycheck-clang-language-standard . "c++11")
     (flycheck-gcc-language-standard . "c++11")
     (Package CLOSETTE :USE LISP)
     (Package . CLOSETTE)
     (Syntax . Common-lisp)
     (Base . 10)
     (Package . NEWCL)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

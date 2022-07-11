;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "alexyavo"
      user-mail-address "alxndr.yav@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
(setq doom-font (font-spec :family "Source Code Pro Medium" :size 14 :weight 'normal))

;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-monokai-classic)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq display-line-numbers-type 'relative)

(global-visual-line-mode t)

(setq-default indent-tabs-mode nil) ;; by default, indent with spaces only (no tabs)
(setq default-tab-width 2)

(setq +evil-want-o/O-to-continue-comments nil)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; https://github.com/doomemacs/doomemacs/issues/1642#issuecomment-518711170

(remove-hook 'doom-first-buffer-hook #'global-hl-line-mode)
(remove-hook 'doom-first-input-hook #'evil-snipe-mode)  ;; give me s/S back


(use-package! utils :load-path "mycode")

(use-package! server :config (unless (server-running-p) (server-start)))

;; (use-package! evil-terminal-cursor-changer
;;   :init
;;   (setq evil-motion-state-cursor 'box)  ; █
;;   (setq evil-visual-state-cursor 'box)  ; █
;;   (setq evil-normal-state-cursor 'box)  ; █
;;   (setq evil-insert-state-cursor 'bar)  ; ⎸
;;   (setq evil-emacs-state-cursor  'hbar) ; _
;;   :hook (tty-setup . evil-terminal-cursor-changer-activate))

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

(use-package! json-mode
  :config (add-hook 'json-mode-hook (lambda ()
                                      (make-local-variable 'js-indent-level)
                                      (setq js-indent-level 2))))
(use-package! json-reformat
  :config (progn
            (setq json-reformat:indent-width 2)
            (global-set-key (kbd "C-c j f") 'json-reformat-region)))

(use-package! poetry
  :hook (python-mode . poetry-tracking-mode))


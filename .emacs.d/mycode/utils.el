(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defun rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

(defun browse-current-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))

(defun copy-file-path-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun refresh-file ()
  (interactive)
  (revert-buffer t t t))

(defun org-to-html-clipboard ()
  "Convert clipboard contents from HTML to Org and then paste (yank).
https://emacs.stackexchange.com/questions/12121/org-mode-parsing-rich-html-directly-when-pasting/12124#12124"
  (interactive)
  (kill-new (shell-command-to-string "osascript -e 'the clipboard as \"HTML\"' | perl -ne 'print chr foreach unpack(\"C*\",pack(\"H*\",substr($_,11,-3)))' | pandoc -f html -t json | pandoc -f json -t org"))
  (yank))

(defun kill-matching-buffers (regexp &optional internal-too)
  "Kill buffers whose name matches the specified REGEXP.
The optional second argument indicates whether to kill internal buffers too."
  (interactive "sKill buffers matching this regular expression: \nP")
  (dolist (buffer (buffer-list))
    (let ((name (buffer-name buffer)))
      (when (and name (not (string-equal name ""))
                 (or internal-too (/= (aref name 0) ?\s))
                 (string-match regexp name))
        (kill-buffer buffer)))))

(defun increment-number-at-point ()
  (interactive)
  (skip-chars-backward "0-9")
  (or (looking-at "[0-9]+")
      (error "No number at point"))
  (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))

;; setup scrolling with ctrl-alt-pgdown/up
(defun scroll-down-keep-cursor ()
  ;; Scroll the text one line down while keping the cursor
  (interactive)
  (scroll-down 1))

(defun scroll-up-keep-cursor ()
  ;; Scroll the text one line up while keepng the cursor
  (interactive)
  (scroll-up 1))

(defun pkg/ensure-installed (&rest packages)
  "Assure every package is installed. Return a list of installed
packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (when (not (package-installed-p package))
       (package-install package)))
   packages))

(defun pkg/upgrade-all ()
  "Upgrade all packages automatically without showing *Packages* buffer."
  (interactive)
  (package-refresh-contents)
  (let (upgrades)
    (cl-flet ((get-version (name where)
                           (let ((pkg (cadr (assq name where))))
                             (when pkg
                               (package-desc-version pkg)))))
      (dolist (package (mapcar #'car package-alist))
        (let ((in-archive (get-version package package-archive-contents)))
          (when (and in-archive
                     (version-list-< (get-version package package-alist)
                                     in-archive))
            (push (cadr (assq package package-archive-contents))
                  upgrades)))))
    (if upgrades
        (when (yes-or-no-p
               (message "Upgrade %d package%s (%s)? "
                        (length upgrades)
                        (if (= (length upgrades) 1) "" "s")
                        (mapconcat #'package-desc-full-name upgrades ", ")))
          (save-window-excursion
            (dolist (package-desc upgrades)
              (let ((old-package (cadr (assq (package-desc-name package-desc)
                                             package-alist))))
                (package-install package-desc)
                (package-delete  old-package)))))
      (message "All packages are up to date"))))


(defun dired-sort ()
  "Sort dired dir listing in different ways.
Prompt for a choice.
URL `http://ergoemacs.org/emacs/dired_sort.html'
Version 2015-07-30"
  (interactive)
  (let (-sort-by -arg)
    (setq -sort-by (ido-completing-read "Sort by:" '( "date" "size" "name" "dir")))
    (cond
     ((equal -sort-by "name") (setq -arg "-Al --si --time-style long-iso "))
     ((equal -sort-by "date") (setq -arg "-Al --si --time-style long-iso -t"))
     ((equal -sort-by "size") (setq -arg "-Al --si --time-style long-iso -S"))
     ((equal -sort-by "dir") (setq -arg "-Al --si --time-style long-iso --group-directories-first"))
     (t (error "logic error 09535" )))
    (dired-sort-other -arg )))

(defun flush-empty-lines ()
  (interactive)
  (flush-lines "^[[:space:]]*$"))


(defvar ascii-sep-list
  '(("nyan1"
     "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░░
░░░░░░░░▄▀░░░░░░░░░░░░▄░░░░░░░▀▄░░░░░░░
░░░░░░░░█░░▄░░░░▄░░░░░░░░░░░░░░█░░░░░░░
░░░░░░░░█░░░░░░░░░░░░▄█▄▄░░▄░░░█░▄▄▄░░░
░▄▄▄▄▄░░█░░░░░░▀░░░░▀█░░▀▄░░░░░█▀▀░██░░
░██▄▀██▄█░░░▄░░░░░░░██░░░░▀▀▀▀▀░░░░██░░
░░▀██▄▀██░░░░░░░░▀░██▀░░░░░░░░░░░░░▀██░
░░░░▀████░▀░░░░▄░░░██░░░▄█░░░░▄░▄█░░██░
░░░░░░░▀█░░░░▄░░░░░██░░░░▄░░░▄░░▄░░░██░
░░░░░░░▄█▄░░░░░░░░░░░▀▄░░▀▀▀▀▀▀▀▀░░▄▀░░
░░░░░░█▀▀█████████▀▀▀▀████████████▀░░░░
░░░░░░████▀░░███▀░░░░░░▀███░░▀██▀░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░")

    ("nyan2"
     "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░░
░░░░░░░░▄▀░░░░░░░░░░░░▄░░░░░░░▀▄░░░░░░░
░░░░░░░░█░░▄░░░░▄░░░░░░░░░░░░░░█░░░░░░░
░░░░░░░░█░░░░░░░░░░░░▄█▄▄░░▄░░░█░▄▄▄░░░
░▄▄▄▄▄░░█░░░░░░▀░░░░▀█░░▀▄░░░░░█▀▀░██░░
░██▄▀██▄█░░░▄░░░░░░░██░░░░▀▀▀▀▀░░░░██░░
░░▀██▄▀██░░░░░░░░▀░██▀░░░░░░░░░░░░░▀██░
░░░░▀████░▀░░░░▄░░░██░░████▀▀▀███▀░░██░
░░░░░░░▀█░░░░▄░░░░░██░░░░▄░░░▄░░▄░░░██░
░░░░░░░▄█▄░░░░░░░░░░░▀▄░░▀▀▀▀▀▀▀▀░░▄▀░░
░░░░░░█▀▀█████████▀▀▀▀████████████▀░░░░
░░░░░░████▀░░███▀░░░░░░▀███░░▀██▀░░░░░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░")

    ("ass"
     "░░░░░░░░░░░█▀▀░░█░░░░░░
░░░░░░▄▀▀▀▀░░░░░█▄▄░░░░
░░░░░░█░█░░░░░░░░░░▐░░░
░░░░░░▐▐░░░░░░░░░▄░▐░░░
░░░░░░█░░░░░░░░▄▀▀░▐░░░
░░░░▄▀░░░░░░░░▐░▄▄▀░░░░
░░▄▀░░░▐░░░░░█▄▀░▐░░░░░
░░█░░░▐░░░░░░░░▄░█░░░░░
░░░█▄░░▀▄░░░░▄▀▐░█░░░░░
░░░█▐▀▀▀░▀▀▀▀░░▐░█░░░░░
░░▐█▐▄░░▀░░░░░░▐░█▄▄░░░
░░░▀▀▄░░░░░░░░▄▐▄▄▄▀░░░
░░░░░░░░░░░░░░░░░░░░░░░")

    ("tank"
     "░░░░░░███████ ]▄▄▄▄▄▄▄▄▃
▂▄▅█████████▅▄▃▂
I███████████████████].
◥⊙▲⊙▲⊙▲⊙▲⊙▲⊙▲⊙◤")

    ("fail"
     "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
████▌▄▌▄▐▐▌█████
████▌▄▌▄▐▐▌▀████
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀")

    ("fu"
     "╭∩╮( º.º )╭∩╮ | ╭∩╮( º.º )╭∩╮ | ╭∩╮( º.º )╭∩╮ | ╭∩╮( º.º )╭∩╮ | ╭∩╮( º.º )╭∩╮")

    ("no wai"
     "⣿⣿⣿⠛⠉⢀⣤⣀⠄⠄⠄⠄⠄⠄⠄⠄⠄⠻⠷⠄⠄⠄⢘⣲⣄⠉⢻⣿⣿⣿
⣿⠛⠁⠄⢸⣿⣿⡿⣋⣤⠤⠄⠄⣀⣀⣀⡀⠄⠄⠄⣀⣤⣤⣤⣤⣅⡀⠹⣿⣿
⠇⠄⠌⢀⣿⣿⣿⣿⠟⣁⣴⣾⣿⣿⠟⡛⠛⢿⣆⢸⣿⣿⣿⠫⠄⠈⢻⠄⢹⣿
⠄⠘⠄⣸⣿⣿⣿⣿⡐⣿⣿⣿⣿⣿⣄⠅⢀⣼⡿⠘⢿⣿⣿⣷⣥⣴⡿⠄⢸⣿
⠄⠃⠄⣿⣿⣿⣿⣿⣷⣬⡙⠻⠿⠿⠿⠿⠟⠋⠁⣠⡀⠠⠭⠭⠭⢥⣤⠄⢸⣿
⢸⠄⢸⣿⣿⣿⣿⣿⣿⣿⣉⣛⠒⠒⠒⢂⣁⣠⣴⣿⣿⣿⣶⣶⣶⣿⣿⡇⠄⣿
⣿⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠋⠉⠉⠛⢿⣿⣿⣿⡇⠄⣿
⡏⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠄⠄⠄⠄⠄⠄⠈⢻⣿⣿⠃⢀⣿
⡇⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠇⠄⠄⠄⠄⠄⠄⠄⠄⠈⣿⣿⠄⢸⣿
⡇⠄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⠄⠹⣶⣄⠄⠄⠄⠄⠄⠄⠄⠘⠛⢿⠄⢸⣿
⠃⠠⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⢰⣿⣿⣧⠄⡀⠄⢀⣠⣶⣿⠗⠄⢀⣾⣿
⠄⠄⠄⠄⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⠈⣿⣿⠃⠄⣩⣴⣿⣿⣿⣃⣤⣶⠄⢹⣿
⠄⠄⠄⠄⠄⠄⠄⠉⠻⢿⣿⣿⣿⡟⢠⣿⣧⣴⣿⣿⣿⣿⣿⣿⣿⣿⣋⡀⠘⣿
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠉⠛⠁⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠄⠻
⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⡖")
    ))

(defun ascii-sep/insert ()
  (interactive)
  (let ((choice (completing-read "Select: " ascii-sep-list)))
    (insert (cadr (assoc choice ascii-sep-list)))))

(defun join-dirs (root &rest dirs)
  "akin to python's os.path.join"
  ;; (joindirs "/tmp" "a" "b")
  ;; "/tmp/a/b"
  ;; (joindirs "~" ".emacs.d" "src")
  ;; "/Users/dbr/.emacs.d/src"
  ;; (joindirs "~" ".emacs.d" "~tmp")
  ;; "/Users/dbr/.emacs.d/~tmp"
  (if (not dirs)
      root
    (apply 'join-dirs
           (expand-file-name (car dirs) root)
           (cdr dirs))))

(provide 'utils)

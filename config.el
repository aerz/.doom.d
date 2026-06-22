;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; -----------------------------------------------------------------------------
;; Global
;; -----------------------------------------------------------------------------

(setq user-full-name "Agustin Cisneros"
      user-mail-address "agustincc@tutanota.com"

      doom-theme 'doom-tomorrow-night
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      doom-variable-pitch-font (font-spec :family "Inter" :size 16)

      display-line-numbers-type nil)

;; -----------------------------------------------------------------------------
;; Workspaces
;; -----------------------------------------------------------------------------

;; Do not create a new perspective for a new frame
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override 'main
        persp-init-new-frame-behaviour-override 'main))

;; -----------------------------------------------------------------------------
;; Terminal
;; -----------------------------------------------------------------------------

;; Use bash internally (POSIX-compliant) but keep fish for interactive terminals
(let ((fish-shell (or (getenv "SHELL") (executable-find "fish"))))
  (setq shell-file-name (or (executable-find "bash") shell-file-name))
  (when fish-shell
    (setq-default explicit-shell-file-name fish-shell
                  vterm-shell fish-shell)))

;; -----------------------------------------------------------------------------
;; Snippets
;; -----------------------------------------------------------------------------

(after! yasnippet
  (add-to-list 'warning-suppress-types '(yasnippet backquote-change)))

;; -----------------------------------------------------------------------------
;; Workarounds
;; -----------------------------------------------------------------------------

(after! diff-hl
  ;; FIXME: Remove on Emacs 31+ or diff-hl update (macOS async buffer sync bug)
  (setq diff-hl-update-async nil)
  (add-hook 'find-file-hook #'diff-hl-update 'append))

;; -----------------------------------------------------------------------------
;; Modules
;; -----------------------------------------------------------------------------

(load! "modules/lang/ansible.el")
(load! "modules/lang/jinja2.el")
(load! "modules/lang/nix.el")
(load! "modules/lang/org.el")
(load! "modules/lang/sh.el")
(load! "modules/lang/typst.el")
(load! "modules/ui.el")

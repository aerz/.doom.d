;;; lang/org.el -*- lexical-binding: t; -*-

(after! org
  (when (eq system-type 'darwin)
    (setq org-directory "~/Documents/Emacs"))
  (setq org-startup-folded t
        org-ellipsis " ▾"))

(after! org-agenda
  (setq org-agenda-include-diary t
        org-agenda-start-on-weekday 1))

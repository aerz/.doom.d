;;; ui.el -*- lexical-binding: t; -*-

;; disable titlebar with round corners
(add-to-list 'default-frame-alist '(undecorated-round . t))

;; sync theme with system dark/light mode (emacs-plus)
(when (eq system-type 'darwin)
  (defun my/apply-theme (appearance)
    "Apply doom theme based on macOS APPEARANCE."
    (pcase appearance
      ('light (load-theme 'doom-tomorrow-day t))
      ('dark  (load-theme 'doom-tomorrow-night t))))

  (add-hook 'ns-system-appearance-change-functions #'my/apply-theme))

(after! doom-modeline
  (when (daemonp)
    (add-hook 'server-after-make-frame-hook #'doom-modeline-mode)))

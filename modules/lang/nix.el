;;; lang/nix.el -*- lexical-binding: t; -*-

(after! nix-mode
  (set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode)))

(setq-hook! 'nix-mode-hook +format-with-lsp nil)

;; sync env to emacs when entering a new project
(after! envrc
  (defvar aerz--doom-env-last-dir nil)

  (defun aerz/doom-sync-env ()
    (when (eq envrc--status 'on)
      (let ((env-dir (envrc--find-env-dir)))
        (when (and env-dir
                   (not (equal env-dir aerz--doom-env-last-dir)))
          (setq aerz--doom-env-last-dir env-dir)
          (let ((proc (start-process-shell-command
                       "doom-sync-env" nil
                       "doom sync --env")))
            (set-process-sentinel
             proc
             (lambda (p _event)
               (when (and (eq (process-status p) 'exit)
                          (zerop (process-exit-status p)))
                 (doom/reload-env)))))))))

  (add-hook! 'envrc-mode-hook #'aerz/doom-sync-env))

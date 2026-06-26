;;; lang/nix.el -*- lexical-binding: t; -*-

(after! nix-mode
  (set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode)))

(setq-hook! 'nix-mode-hook +format-with-lsp nil)

;; Resolves tool binaries provided by the project's Nix flake (via direnv).
;; Caches the absolute store path so `direnv exec . which' runs once.

(defvar nix-flake--cache nil
  "Alist mapping binary name -> absolute Nix store path.")

;;;###autoload
(defun nix-flake-exec-path (binary)
  "Return the Nix store path for BINARY inside the project flake.
Resolves and caches the result; re-resolves if cached path is stale."
  (or (alist-get binary nix-flake--cache nil nil #'equal)
      (let* ((default-directory
              (project-root (or (project-current)
                                (user-error "Not inside a project"))))
             (path (string-trim
                    (shell-command-to-string
                     (format "direnv exec . which %s 2>/dev/null"
                             (shell-quote-argument binary))))))
        (unless (and path (file-executable-p path))
          (user-error "Could not find `%s' in the project's Nix environment" binary))
        (push (cons binary path) nix-flake--cache)
        path)))

;;;###autoload
(defun nix-flake-reset-cache ()
  "Clear cached binary paths (e.g. after `nix flake update')."
  (interactive)
  (setq nix-flake--cache nil)
  (message "Nix flake cache cleared"))

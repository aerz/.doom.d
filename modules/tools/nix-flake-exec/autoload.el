;;; tools/nix-flake-exec/autoload.el -*- lexical-binding: t; -*-

;; Resolves tool binaries provided by the project's Nix flake (via direnv).
;; Caches the absolute store path so `direnv exec . which' runs once.
;; When no flake + direnv environment is detected, falls back to
;; returning the bare binary name for PATH resolution.

(defvar nix-flake-exec--cache nil
  "Alist mapping binary name -> absolute Nix store path.")

;;;###autoload
(defun nix-flake-exec-path (binary)
  "Return the Nix store path for BINARY inside the project flake.

Resolves and caches the result so `direnv exec . which' runs at most
once per binary per session.

If the project does not have a `.envrc` file and `direnv` installed,
or the binary isn't provided by the flake, return just BINARY so it
resolves via `exec-path'.  This makes the function safe to call from
any project without requiring a Nix flake environment."
  (or (alist-get binary nix-flake-exec--cache nil nil #'equal)
      (let* ((root (project-root (or (project-current)
                                     (user-error "Not inside a project"))))
             (envrc (expand-file-name ".envrc" root))
             (path (when (and (executable-find "direnv")
                              (file-exists-p envrc))
                     (string-trim
                      (shell-command-to-string
                       (format "cd %s && direnv exec . which %s 2>/dev/null"
                               (shell-quote-argument root)
                               (shell-quote-argument binary)))))))
        (if (and path (file-executable-p path))
            ;; Flake + direnv active and binary resolved
            (progn
              (push (cons binary path) nix-flake-exec--cache)
              path)
          ;; No flake/direnv, or binary not in flake – resolve via PATH
          binary))))

;;;###autoload
(defun nix-flake-exec-reset-cache ()
  "Clear cached binary paths (e.g. after `nix flake update')."
  (interactive)
  (setq nix-flake-exec--cache nil)
  (message "Nix flake cache cleared"))

;;; lang/nix.el -*- lexical-binding: t; -*-

;; Formatter for nix files
(after! nix-mode
  (set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode)))

;;  Disable LSP formatting — alejandra handles it
(setq-hook! 'nix-mode-hook +format-with-lsp nil)

;; -----------------------------------------------------------------------------
;; Eglot on envrc
;; -----------------------------------------------------------------------------
;; Ensure eglot starts when a buffer enters a direnv
;; environment. envrc already sets buffer-local PATH and
;; env vars — we just need to kick off the LSP client.
(after! envrc
  (add-hook! 'envrc-mode-hook
    (defun +aerz--eglot-on-envrc-h ()
      (when (eq envrc--status 'on)
        (eglot-ensure)))))

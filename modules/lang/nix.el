;;; lang/nix.el -*- lexical-binding: t; -*-

(after! nix-mode
  (set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode)))

(setq-hook! 'nix-mode-hook +format-with-lsp nil)

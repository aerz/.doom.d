;;; lang/astro.el -*- lexical-binding: t; -*-

;; Autoloads are disabled in packages.el; register the mode manually.
(autoload 'astro-ts-mode "astro-ts-mode" "Astro major mode." t)
(add-to-list 'auto-mode-alist '("\\.astro\\'" . astro-ts-mode))
(add-hook 'astro-ts-mode-hook #'lsp!)

(after! eglot
  ;; astro-ls requires a typescript.tsdk; relative to the project root.
  (add-to-list 'eglot-server-programs
               '(astro-ts-mode "astro-ls" "--stdio"
                 :initializationOptions
                 (:typescript (:tsdk "node_modules/typescript/lib")))))

(after! apheleia
  (set-formatter! 'prettier-astro
    '("apheleia-npx" "prettier" "--stdin-filepath" filepath "--parser=astro")
    :modes 'astro-ts-mode))

;;; init.el -*- lexical-binding: t; -*-

(doom! :completion
       (corfu +icons +orderless)
       (vertico +icons)

       :ui
       doom
       dashboard
       hl-todo
       ligatures
       modeline
       ophints
       (popup +defaults)
       (smooth-scroll +interpolate)
       (vc-gutter +pretty)
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       multiple-cursors
       snippets
       (whitespace +guess +trim)

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       (syntax +flymake +icons)

       :tools
       ansible
       magit
       lookup
       (lsp +eglot +booster)
       pdf
       tree-sitter

       :os
       tty

       :lang
       (javascript +lsp +tree-sitter)
       json
       (org +pandoc)
       (python +lsp +tree-sitter)
       (sh +fish +lsp)
       emacs-lisp
       markdown
       (nix +lsp)
       web
       (yaml +lsp +tree-sitter)

       :config
       (default +bindings +smartparens))

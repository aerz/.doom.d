;;; lang/js.el -*- lexical-binding: t; -*-

;; package.json is not JavaScript, remove from ts-lsp
;; session inherited from `js-mode'
(add-to-list 'auto-mode-alist
             '("package\\.json\\'" . js-json-mode))

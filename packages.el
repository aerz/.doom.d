;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! dotenv-mode)
(package! just-mode)
(package! nginx-mode)
(package! pkgbuild-mode)
(package! jinja2-mode)
(package! systemd)
(package! polymode)
(package! poly-ansible)
(package! treesit-auto)
(package! typst-ts-mode
  :recipe (:host codeberg :repo "meow_king/typst-ts-mode"))
(package! expreg)

;; FIXME: Remove on Emacs 31+ (emacs-mirror/emacs@dc41ddb)
(package! solaire-mode :disable t)

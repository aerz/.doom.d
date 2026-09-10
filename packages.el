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
(package! typst-ts-mode
  :recipe (:host codeberg :repo "meow_king/typst-ts-mode"))
(package! expreg)

;; Upstream's autoloads call unbound `treesit-ready-p', breaking `doom sync'.
(package! astro-ts-mode
  :recipe (:type git
           :repo "https://git.isincredibly.gay/srxl/astro-ts-mode.git"
           :local-repo "astro-ts-mode"
           :build (:not autoloads)))

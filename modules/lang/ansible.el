;;; langs/ansible.el -*- lexical-binding: t; -*-

(after! yaml-mode
  (setq lsp-yaml-custom-tags '("!vault")))

(use-package! poly-ansible
  :after systemd)

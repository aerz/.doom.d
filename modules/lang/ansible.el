;;; lang/ansible.el -*- lexical-binding: t; -*-

(after! yaml-mode
  (setq lsp-yaml-custom-tags '("!vault")))

(use-package! poly-ansible
  :after systemd)

;; Wire up ansible-vault-inline with our Nix environment
(setq ansible-vault-inline-program
      (lambda () (nix-flake-exec-path "ansible-vault")))

(after! ansible
  (advice-add 'ansible-vault :around
              (lambda (orig-fn mode str params)
                (let* ((av (nix-flake-exec-path "ansible-vault"))
                       (av-dir (file-name-directory av)))
                  (let ((exec-path (if av-dir (cons av-dir exec-path) exec-path))
                        (new-params (append params '("--output" "-"))))
                    (funcall orig-fn mode str new-params))))))

(map! :map ansible-key-map
      :localleader
      :desc "Decrypt vault at point" "i" #'ansible-vault-inline-at-point)

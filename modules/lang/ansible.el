;;; lang/ansible.el -*- lexical-binding: t; -*-

(after! yaml-mode
  (setq lsp-yaml-custom-tags '("!vault")))

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

;; -----------------------------------------------------------------------------
;; Poly-ansible only for Jinja2 templates
;; -----------------------------------------------------------------------------
;; The package's default associations are too broad —
;; they trigger poly-ansible for any yaml under /ansible/
;; or in host/group_vars. We scope it to .yaml.j2/.yml.j2
;; only, using cl-remove-if for robustness.
(use-package! poly-ansible
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\.j2\\'" . poly-ansible-mode))

  :config
  (setq auto-mode-alist
        (cl-remove-if (lambda (entry)
                        (memq (cdr entry) '(poly-ansible-mode)))
                      auto-mode-alist))
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\.j2\\'" . poly-ansible-mode))

  (when (featurep 'treesit)
    (define-hostmode poly-yaml-ts-hostmode :mode 'yaml-mode)))

;;; lang/ansible.el -*- lexical-binding: t; -*-

(after! yaml-mode
  (setq lsp-yaml-custom-tags '("!vault")))

(use-package! poly-ansible
  :after systemd)

(after! ansible
  (setq ansible-vault-password
        (lambda ()
          (let* ((script (expand-file-name "secrets/decrypt_vault_secret.sh"
                                           (project-root (project-current))))
                 (pass (string-trim (shell-command-to-string script))))
            (ansible-vault-create-temp-password-file pass))))

  (advice-add 'ansible-vault :around
              (lambda (orig-fn mode str params)
                (let* ((av (nix-flake-exec-path "ansible-vault"))
                       (new-params (append params '("--output" "-"))))
                  (let ((exec-path (cons (file-name-directory av) exec-path)))
                    (funcall orig-fn mode str new-params))))))


(defconst aes/vault--block-header-re "!vault[ \t]*|[-+0-9]*"
  "Regexp matching a `!vault' block-scalar header.")

(defconst aes/vault-password-script "secrets/decrypt_vault_secret.sh"
  "Vault password script path, relative to project root.")

(defun aes/vault--block-header-end ()
  "Return end position of `!vault |' header above point, or nil."
  (save-excursion
    (end-of-line)
    (when (re-search-backward aes/vault--block-header-re nil t)
      (line-end-position))))

(defun aes/vault--collect-block-lines ()
  "Collect raw lines of the `!vault' block scalar enclosing point."
  (save-excursion
    (let ((header-end (aes/vault--block-header-end)))
      (when header-end
        (goto-char header-end) (forward-line 1)
        (let (lines indent)
          (catch 'done
            (while (not (eobp))
              (let* ((line (buffer-substring-no-properties (point) (line-end-position)))
                     (lead (progn (string-match "\\`[ \t]*" line) (match-end 0)))
                     (blank (= lead (length line))))
                (cond (blank (push line lines))
                      ((null indent)
                       (if (> lead 0) (progn (setq indent lead) (push line lines))
                         (throw 'done nil)))
                      ((>= lead indent) (push line lines))
                      (t (throw 'done nil))))
              (forward-line 1)))
          (nreverse lines))))))

(defun aes/vault--dedent-lines (lines)
  "Strip shared block indentation from LINES and join them."
  (when lines
    (let ((indent (seq-some (lambda (line)
                              (string-match "\\`[ \t]*" line)
                              (and (< (match-end 0) (length line)) (match-end 0)))
                            lines)))
      (mapconcat (lambda (line)
                   (if (and indent (>= (length line) indent))
                       (substring line indent) line))
                 lines "\n"))))

(defun aes/vault-content-at-point ()
  "Return de-indented `!vault' block content at point, or nil."
  (aes/vault--dedent-lines (aes/vault--collect-block-lines)))

(defun aes/ansible-vault--decrypt (ciphertext root)
  "Decrypt CIPHERTEXT (a `!vault' block) and return plaintext.
ROOT is the project root directory."
  (let ((av (nix-flake-exec-path "ansible-vault"))
        (pass-file (expand-file-name aes/vault-password-script root))
        (temp (make-temp-file "ansible-vault-inline")))
    (unwind-protect
        (with-temp-buffer
          (write-region ciphertext nil temp nil 'silent)
          (let* ((default-directory root)
                 (status (call-process av nil t nil "decrypt" "--output" "-"
                                       (concat "--vault-password-file=" pass-file)
                                       temp))
                 (output (string-trim (buffer-string))))
            (if (eq status 0) output
              (user-error "ansible-vault decrypt failed: %s" output))))
      (when (file-exists-p temp) (ignore-errors (delete-file temp))))))

;;;###autoload
(defun aes/ansible-vault-at-point ()
  "Decrypt `!vault' block at point and show in minibuffer."
  (interactive)
  (let* ((root (project-root (or (project-current)
                                 (user-error "Not inside a project"))))
         (ciphertext (or (aes/vault-content-at-point)
                         (user-error "No !vault value at point"))))
    (message "🔓 %s" (aes/ansible-vault--decrypt ciphertext root))))


(map! :map ansible-key-map
      :localleader
      :desc "Decrypt value at point" "i" #'aes/ansible-vault-at-point)

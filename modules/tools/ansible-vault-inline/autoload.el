;;; tools/ansible-vault-inline/autoload.el -*- lexical-binding: t; -*-

;; ── Internal helpers ──────────────────────────────────────────

(defconst ansible-vault-inline--block-header-re
  "!vault[ \t]*|[-+0-9]*"
  "Regexp matching a `!vault' block-scalar header.")

(defun ansible-vault-inline--resolve-program ()
  "Return the absolute path to the ansible-vault binary."
  (let ((prog ansible-vault-inline-program))
    (cond
     ((functionp prog)
      (or (funcall prog)
          (user-error "`ansible-vault-inline-program' function returned nil")))
     ((stringp prog)
      (or (executable-find prog)
          (user-error "Could not find `%s' in `exec-path'" prog)))
     (t (user-error "Invalid `ansible-vault-inline-program': %S" prog)))))

(defun ansible-vault-inline--resolve-password-file ()
  "Return the vault password file path, or nil to prompt."
  (cond
   ((functionp ansible-vault-inline-password-file)
    (funcall ansible-vault-inline-password-file))
   ((stringp ansible-vault-inline-password-file)
    (expand-file-name ansible-vault-inline-password-file))
   (t nil)))

;; ── Block extraction ──────────────────────────────────────────

(defun ansible-vault-inline--block-header-end ()
  "Return end position of the `!vault' header above point, or nil."
  (save-excursion
    (end-of-line)
    (when (re-search-backward ansible-vault-inline--block-header-re nil t)
      (line-end-position))))

(defun ansible-vault-inline--collect-block-lines ()
  "Collect the raw lines of the `!vault' block scalar enclosing point."
  (save-excursion
    (let ((header-end (ansible-vault-inline--block-header-end)))
      (when header-end
        (goto-char header-end)
        (forward-line 1)
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

(defun ansible-vault-inline--dedent-lines (lines)
  "Strip shared block indentation from LINES and join them as a single string."
  (when lines
    (let ((indent (seq-some (lambda (line)
                              (string-match "\\`[ \t]*" line)
                              (and (< (match-end 0) (length line)) (match-end 0)))
                            lines)))
      (mapconcat (lambda (line)
                   (if (and indent (>= (length line) indent))
                       (substring line indent)
                     line))
                 lines "\n"))))

;;;###autoload
(defun ansible-vault-inline-content-at-point ()
  "Return the de-indented `!vault' block content at point, or nil."
  (ansible-vault-inline--dedent-lines
   (ansible-vault-inline--collect-block-lines)))

;; ── Decryption ────────────────────────────────────────────────

;;;###autoload
(defun ansible-vault-inline-decrypt (ciphertext &optional root)
  "Decrypt CIPHERTEXT (a `!vault' block scalar) and return plaintext.
ROOT is the project root directory (defaults to `default-directory')."
  (let* ((root (or root default-directory))
         (av (ansible-vault-inline--resolve-program))
         (pass-file (ansible-vault-inline--resolve-password-file))
         (temp (make-temp-file "ansible-vault-inline")))
    (unwind-protect
        (with-temp-buffer
          (write-region ciphertext nil temp nil 'silent)
          (let* ((default-directory root)
                 (args `("decrypt" "--output" "-"
                         ,@(when pass-file
                             (list (concat "--vault-password-file=" pass-file)))
                         ,temp))
                 (status (apply #'call-process av nil t nil args))
                 (output (string-trim (buffer-string))))
            (if (eq status 0) output
              (user-error "ansible-vault decrypt failed: %s" output))))
      (when (file-exists-p temp)
        (ignore-errors (delete-file temp))))))

;;;###autoload
(defun ansible-vault-inline-at-point ()
  "Decrypt the `!vault' block at point and show the result in the minibuffer."
  (interactive)
  (let* ((project (or (project-current)
                      (user-error "Not inside a project")))
         (root (project-root project))
         (ciphertext (or (ansible-vault-inline-content-at-point)
                         (user-error "No !vault value at point"))))
    (message "🔓 %s" (ansible-vault-inline-decrypt ciphertext root))))

;;; tools/ansible-vault-inline/config.el -*- lexical-binding: t; -*-

(defgroup ansible-vault-inline nil
  "Decrypt !vault YAML inline values at point."
  :group 'tools
  :prefix "ansible-vault-inline-")

(defcustom ansible-vault-inline-program "ansible-vault"
  "The ansible-vault command.
If a string, it is looked up via `executable-find'.
If a function, it is called with no arguments and must return
the absolute path to the ansible-vault binary."
  :type '(choice (string :tag "Command name")
                 (function :tag "Function returning path"))
  :group 'ansible-vault-inline
  :risky t)

(defcustom ansible-vault-inline-password-file nil
  "Path to vault password file or executable script.
If nil, you will be prompted for the vault password.
If a function, it is called to return the password file path.
If a string, it is used directly (expanded via `expand-file-name')."
  :type '(choice (file :tag "Password file/script")
                 (function :tag "Function returning path")
                 (const :tag "Prompt for password" nil))
  :group 'ansible-vault-inline
  :risky t)

;;; langs/sh.el -*- lexical-binding: t; -*-

(after! sh-script
  (set-company-backend! 'sh-mode
                        '(company-shell :with company-yasnippet)))

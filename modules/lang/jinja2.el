;;; langs/jinja2.el -*- lexical-binding: t; -*-

(after! jinja2-mode
  (set-formatter! 'prettier-jinja2 :modes '(jinja2-mode)))

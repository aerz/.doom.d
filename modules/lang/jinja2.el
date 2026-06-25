;;; langs/jinja2.el -*- lexical-binding: t; -*-

(after! apheleia
  (set-formatter!
    'prettier-jinja2
    '("prettier"
      "--parser=jinja-template"
      "--stdin-filepath" filepath)))

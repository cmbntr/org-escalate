;;; org-escalate.el
;;
;; Copyright (C) 2012 Michael Locher
;;
;; Author: Michael Locher <cmbntr at gmail dot com>
;; Homepage: https://github.com/cmbntr/org-escalate


(require 'cl)
(require 'org)

(defun org-collect-linking-subheading-ids ()
  (let ((ids nil))
    (org-map-tree
     (lambda ()
       (let ((heading (fifth (org-heading-components))))
         (when (string-match org-bracket-link-regexp heading)
           (let ((target (match-string 1 heading)))
             (when (string-match "^#.*" target)
               (setq ids (cons target ids))))))))
    ids))

(defun org-map-linked-subheadings (func &optional match scope &rest skip)
  (let* ((args (append `(org-collect-linking-subheading-ids ,match ,scope) skip))
         (ids-by-match (apply 'org-map-entries args))
         (ids (nreverse (apply 'concatenate (cons 'list ids-by-match)))))
    (mapcar (lambda (id) (org-map-entries func (format "CUSTOM_ID=\"%s\"" (substring id 1)))) ids)))

(defun org-escalate-todo (todo)
  (interactive (list (org-icompleting-read "Keyword to escalate: " (mapcar 'list org-todo-keywords-1))))
  (org-map-linked-subheadings (lambda () (org-todo todo)) (format "TODO=\"%s\"" todo) 'tree))

(provide 'org-escalate)

;;; org-escalate.el ends here
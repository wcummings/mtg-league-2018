;; utils for publishing org-mode decklists on github

(require 'url-util)

(defvar *mtg-search-url* "http://gatherer.wizards.com/Pages/Card/Details.aspx?name=")

(defun mtg-prepare-card-list ()
  "Create links to oracle text."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (= (point) (point-max)))
      (forward-char 2) ;; FIXME: use search-forward, or interact w/ org headlines
      (let* ((description (get-url-description-at-point))
             (url (concat *mtg-search-url* (url-encode-url description))))
        (delete-region (point) (line-end-position))
        ;; org-insert-link insists on encoding the full URL
        (insert (concat "[[" url "][" description "]]"))
        (outline-next-visible-heading 1)))))

(defun get-url-description-at-point ()
  "Get the URL description from either an org link, or plain text."
  (let* ((link-info (assoc :link (org-context)))
         (text (when link-info
                 ;; org-context seems to return nil if the current element
                 ;; starts at buffer-start or ends at buffer-end
                 (buffer-substring-no-properties (or (cadr link-info) (point-min))
                                                 (or (caddr link-info) (point-max))))))
    (if text
        (progn
          (string-match org-bracket-link-regexp text)
          (substring text (match-beginning 3) (match-end 3)))
      (buffer-substring-no-properties (point) (line-end-position)))))

(provide 'mtg)

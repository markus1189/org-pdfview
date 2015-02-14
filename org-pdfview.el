;;; org-pdfview.el --- Support for links to documents in pdfview mode

;; Copyright (C) 2014 Markus Hauck

;; Author: Markus Hauck <markus1189@gmail.com>
;; Maintainer: Markus Hauck <markus1189@gmail.com>
;; Keywords: org, pdf-view, pdf-tools
;; Version: 0.1
;; Package-Requires: ((org "6.01") (pdf-tools "0.40"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Add support for org links from pdfview buffers like docview.
;;
;; To enable this automatically, use:
;;     (eval-after-load 'org '(require 'org-pdfview))

;;; Code:
(require 'org)
(require 'pdf-tools)
(require 'pdf-view)

(org-add-link-type "pdfview" 'org-pdfview-open 'org-pdfview-export)
(add-hook 'org-store-link-functions 'org-pdfview-store-link)

(defun org-pdfview-open (link)
  "Open LINK in pdf-view-mode."
  (when (string-match "\\(.*\\)::\\([0-9]+\\)$"  link)
    (let* ((path (match-string 1 link))
	   (page (string-to-number (match-string 2 link))))
      (org-open-file path 1)
      (pdf-view-goto-page page))))

(defun org-pdfview-store-link ()
  "Store a link to a pdfview buffer."
  (when (eq major-mode 'pdf-view-mode)
    ;; This buffer is in pdf-view-mode
    (let* ((path buffer-file-name)
	   (page (pdf-view-current-page))
	   (link (concat "pdfview:" path "::" (number-to-string page))))
      (org-store-link-props
       :type "pdfview"
       :link link
       :description path))))

(defun org-pdfview-export (link description format)
  "Export the pdfview LINK with DESCRIPTION for FORMAT from Org files."
  (let* ((path (when (string-match "\\(.+\\)::.+" link)
		 (match-string 1 link)))
         (desc (or description link)))
    (when (stringp path)
      (setq path (org-link-escape (expand-file-name path)))
      (cond
       ((eq format 'html) (format "<a href=\"%s\">%s</a>" path desc))
       ((eq format 'latex) (format "\href{%s}{%s}" path desc))
       ((eq format 'ascii) (format "%s (%s)" desc path))
       (t path)))))

(provide 'org-pdfview)
;;; org-pdfview.el ends here

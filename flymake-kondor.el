;;; flymake-kondor.el --- Linter with clj-kondo -*- lexical-binding: t; -*-

;; Copyright (C) 2019 https://turbocafe.keybase.pub
;;
;; Author: https://turbocafe.keybase.pub
;; Created: 3 November 2019
;; Version: 0.0.3
;; Package-Requires: ((emacs "26.1") (flymake-quickdef "1.0.0"))
;; URL: https://github.com/turbo-cafe/flymake-kondor
;;; Commentary:

;; This package adds Clojure syntax checker clj-kondo.
;; Make sure clj-kondo binary is on your path.
;; Installation instructions https://github.com/borkdude/clj-kondo/blob/master/doc/install.md

;;; License:

;; This file is not part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(require 'flymake)
(require 'flymake-quickdef)

(flymake-quickdef-backend flymake-kondor-backend
  :pre-let ((kondor-exec (executable-find "clj-kondo"))
            (lang (file-name-extension buffer-file-name)))
  :pre-check (unless kondor-exec (error "Not found clj-kondo on PATH"))
  :write-type 'pipe
  :proc-form (list kondor-exec "--lint" "-" "--lang" lang)
  :search-regexp "^.+:\\([[:digit:]]+\\):\\([[:digit:]]+\\): \\([[:alpha:]]+\\): \\(.+\\)$"
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (lcol (string-to-number (match-string 2)))
         (severity (match-string 3))
         (msg (match-string 4))
         (pos (flymake-diag-region fmqd-source lnum lcol))
         (beg (car pos))
         (end (cdr pos))
         (type (cond
                ((string= severity "error") :error)
                ((string= severity "warning") :warning)
                ((string= severity "info") :note)
                (t :note))))
    (list fmqd-source beg end type msg)))
;;;###autoload
(defun flymake-kondor-setup ()
  "Enable flymake backend."
  (add-hook 'flymake-diagnostic-functions #'flymake-kondor-backend nil t))

(provide 'flymake-kondor)

;;; flymake-kondor.el ends here

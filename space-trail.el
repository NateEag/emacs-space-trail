;;; space-trail.el --- Remove trailing whitespace on save when sensible.

;; Copyright 2015 Nate Eagleson
;; Author: Nate Eagleson
;; Keywords: whitespace, trailing whitespace
;; Package-Requires: ((cl-lib "0.5"))
;; Version: 0.1.0

;;; Commentary:

;; To keep files clean and diffs readable, it's nice to strip trailing
;; whitespace on save.
;;
;; To that end, Emacs has the built-in function `delete-trailing-whitespace`.
;; Alas, if you add it to `before-save-hook`, eventually, you will run into
;; problems.
;;
;; Some file types can be damaged by stripping trailing whitespace. Patches,
;; for instance (imagine the pain of trying to figure out how two identical
;; lines could be marked as added and deleted - it me took a while to realize
;; what had happened).
;;
;; Other file types, like Markdown, should have some trailing whitespace
;; stripped, but not all. Blank lines in code blocks should not have trailing
;; whitespace stripped.
;;
;; space-trail teaches Emacs to handle those cases correctly.
;;
;; It also provides extension points so you can teach space-trail to handle
;; cases it doesn't get right. When you find one, please file an issue or a PR.
;;
;;; Basic Setup
;;
;; To have space-trail handle trailing whitespace on save, put this elisp
;; somewhere in your Emacs config (like init.el):
;;
;;     (space-trail-activate)
;;
;; If you need to turn space-trail off temporarily, run
;; `M-x space-trail-deactivate`.
;;
;;; Useful Variables
;;
;; By default, space-trail does not strip whitespace from your current line.
;; You can change that by setting
;; `space-trail-strip-whitespace-on-current-line` to `t`.
;;
;; `space-trail-ignored-modes` is a list of major-modes that should never have
;; trailing whitespace removed. It defaults to `'(diff-mode)`.
;;
;; By default, space-trail will strip trailing whitespace inside programming
;; language strings. Set `space-trail-strip-whitespace-in-strings` to `nil` when
;; you want to suppress that behavior.
;;
;; `space-trail-ignore-buffer` prevents whitespace stripping on a per-buffer
;; basis. It's a good thing to set in `.dir-locals.el` for projects that aren't
;; careful with trailing whitespace, so you don't add noise to diffs.
;;
;;; Known Issues
;;
;; space-trail does not have support for stripping trailing whitespace only on
;; modified lines. It really should.
;;
;; Patches are greatly welcomed.
;;
;;; License:
;;
;; This code is under the two-clause BSD license, which follows:
;;
;; Copyright (c) 2015, Nate Eagleson
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; 1. Redistributions of source code must retain the above copyright notice,
;; this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;; this list of conditions and the following disclaimer in the documentation
;; and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.
;;
;; readme.md is generated from the source code using
;; [md-readme](https://github.com/thomas11/md-readme).

;;; Code:


(defvar space-trail-ignored-modes
  '(diff-mode)
  "A list of modes that should not have trailing whitespace stripped.")

(defvar space-trail-ignore-buffer
  nil
  "If this buffer-local var is t, do not strip trailing whitespace.

An escape hatch that should be useful in .dir-locals.el, if a project
is littered with trailing whitespace and you don't want to fix it right now,
or if a particular file actually needs to contain trailing whitespace.")
(make-variable-buffer-local 'space-trail-ignore-buffer)

(defvar space-trail-prevent-buffer-stripping-predicates
  '(space-trail-ignored-mode-p)
  "A list of functions. If any return true, do not strip current buffer.")

(defvar space-trail-strip-whitespace-on-current-line
  nil
  "If nil, do not strip trailing whitespace on current line.

Nil by default, as it's annoying to lose indentation you just added
intentionally because you saved.")

;; TODO Add a variable to control whether whitespace will be stripped inside
;; strings. Should be doable semi-generally, because syntax tables. Not sure
;; what would be involved.
(defvar space-trail-strip-whitespace-in-strings
  t
  "When t, strip whitespace inside of strings.

If nil, leave such whitespace intact.

Defaults to t, as most of the time trailing whitespace in strings is
probably an accident.

Still, there are cases (such as space-trail's test suite) where you really
do want to preserve trailing whitespace in strings.

Thus, this variable.")

(defvar space-trail-prevent-line-stripping-predicates
  '(space-trail-point-on-line-p
    space-trail-in-markdown-code-block-p
    space-trail-in-string-p)
  "A list of functions that can prevent stripping a line's whitespace.

Before stripping a line's trailing whitespace, each one is called,
passing the current line number and the cursor's current location.

If any function returns true, the line's trailing whitespace won't
be stripped.")

(defun space-trail-point-on-line-p (line-num cursor-pos)
  "Return true if LINE-NUM of current buffer contains CURSOR-POS.

If `space-trail-strip-whitespace-on-current-line' is t, this function
will always return false, effectively deactivating it."
  (and (not space-trail-strip-whitespace-on-current-line)
       (= line-num (line-number-at-pos orig-point))))

(defun space-trail-in-markdown-code-block-p (line-num cur-point)
  "Return `t' if LINE-NUM is part of a Markdown code block.

Always returns `nil' if current buffer is not in markdown-mode.

It is conceivable markdown-mode already has this function and I
just didn't find it."

  ;; TODO Figure out how I should handle dependency on markdown-mode.
  ;; I don't want to require it to install this library - just to have this
  ;; library do the right thing in markdown-mode buffers.
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- line-num))
    (and (eq major-mode 'markdown-mode)
         (>= (markdown-cur-line-indent) 4))))

(defun space-trail-in-string-p (line-num cur-point)
  "Return t if LINE-NUM's trailing space is inside a string.

Otherwise, return nil.

Always return nil if `space-trail-strip-whitespace-in-strings' is t,
thereby effectively deactivating this function.

Relies on `syntax-ppss'."

  (if space-trail-strip-whitespace-in-strings
      nil
    (save-excursion
      (goto-char (point-min))
      (forward-line (1- line-num))
      (move-end-of-line nil)
      (if (nth 8 (syntax-ppss))
          t))))

(defun space-trail-delete-trailing-whitespace (&optional start end)
  "Delete trailing whitespace between START and END.
If called interactively, START and END are the start/end of the
region if the mark is active, or of the buffer's accessible
portion if the mark is inactive.

This command deletes whitespace characters after the last
non-whitespace character in each line between START and END, if none
of the functions in `space-trail-should-strip-line-whitespace-predicates'
return true for that line.  It does not consider formfeed characters to be
whitespace.

If this command acts on the entire buffer (i.e. if called
interactively with the mark inactive, or called from Lisp with
END nil), it also deletes all trailing lines at the end of the
buffer if the variable `delete-trailing-lines' is non-nil.

This is largely `delete-trailing-whitespace', modified
to give space-trail.el a hook point."
  (interactive (progn
                 (barf-if-buffer-read-only)
                 (if (use-region-p)
                     (list (region-beginning) (region-end))
                   (list nil nil))))
  (save-match-data
    (save-excursion
      (let ((end-marker (copy-marker (or end (point-max))))
            (start (or start (point-min)))
            (orig-point (point)))
        (goto-char start)
        (while (re-search-forward "\\s-$" end-marker t)
          (skip-syntax-backward "-" (line-beginning-position))
          (if (or
               ;; Don't delete formfeeds, even if they are considered whitespace.
               (looking-at-p ".*\f")
               ;; Don't delete whitespace protected via space-trail.
               ;; TODO This whole mess should abstracted.
               (cl-some
                (lambda (x) x)
                (mapcar (lambda (func)
                          (funcall func
                                   (line-number-at-pos)
                                   orig-point))
                        space-trail-prevent-line-stripping-predicates)))
              (progn
                (goto-char (match-end 0)))
            (delete-region (point) (match-end 0))))

        ;; Delete trailing empty lines.
        (goto-char end-marker)
        (when (and (not end)
		   delete-trailing-lines
                   ;; Really the end of buffer.
		   (= (point-max) (1+ (buffer-size)))
                   (<= (skip-chars-backward "\n") -2))
          (delete-region (1+ (point)) end-marker))
        (set-marker end-marker nil))))
  ;; Return nil for the benefit of `write-file-functions'.
  nil)

(defun space-trail-maybe-delete-trailing-whitespace ()
  "Delete trailing whitespace in current buffer if appropriate."

  (unless (featurep 'cl-lib)
    (require 'cl-lib))

  (unless (or
           space-trail-ignore-buffer
           (cl-some
            (lambda (x) x)
            (mapcar 'funcall space-trail-prevent-buffer-stripping-predicates)))
        (space-trail-delete-trailing-whitespace)))

(defun space-trail-ignored-mode-p (&optional buffer-or-string)
  "Return true if `BUFFER-OR-STRING's `major-mode' should not be stripped.

`BUFFER-OR-STRING' defaults to (current-buffer)."

  (with-current-buffer (or buffer-or-string (current-buffer))
    (member major-mode space-trail-ignored-modes)))

;;;###autoload
(defun space-trail-activate ()
  "Remove meaningless trailing whitespace before saving."

  (interactive)
  (add-hook 'before-save-hook 'space-trail-maybe-delete-trailing-whitespace))

;;;###autoload
(defun space-trail-deactivate ()
  "Stop removing meaningless trailing whitespace before saving."

  (interactive)
  (remove-hook 'before-save-hook 'space-trail-maybe-delete-trailing-whitespace))

(provide 'space-trail)
;;; space-trail.el ends here

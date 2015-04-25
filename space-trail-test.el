(require 'markdown-mode)
(load-file "space-trail.el")

(defun space-trail-test-next-trailing-whitespace ()
  "Search for next chunk of trailing whitespace."

  (re-search-forward

   ;; 'Whitespace' here is *not* \\s-, because that includes \n\n, which we
   ;; don't want to match. It's a character class matching space and tab.
   ;;
   ;; If one of those is followed by end-of-line or end-of-buffer, then we
   ;; know it's trailing.
   "[ 	]+\\($\\|\\'\\)"
   nil t))

(describe "space-trail-maybe-delete-trailing-whitespace"

          (before-each
           (get-buffer-create "space-trail-test")
           (set-buffer "space-trail-test")

           (erase-buffer)
           (insert "This is a string

which has some trailing whitespace    ")
           (goto-char 0))

          (after-each
            (kill-buffer "space-trail-test"))

          (it "removes a buffer's trailing whitespace."
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (space-trail-test-next-trailing-whitespace) :to-be nil))

          (it "does not remove trailing space in ignored modes."
              (diff-mode)
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil)
              (fundamental-mode))

          (it "does not remove trailing space in opted-out buffers."
            (get-buffer-create "space-trail-test-ignored")
            (set-buffer "space-trail-test-ignored")
            (setq space-trail-ignore-buffer t)

            (insert "This is a string

which has some trailing whitespace    ")
            (goto-char 0)

            (space-trail-maybe-delete-trailing-whitespace)

            (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil)

            (kill-buffer "space-trail-test-ignored")

            (set-buffer "space-trail-test")

            (space-trail-maybe-delete-trailing-whitespace)

            (expect (space-trail-test-next-trailing-whitespace) :to-be nil))

          (it "removes trailing space on current line only if asked."
              (goto-line 3)
              (space-trail-maybe-delete-trailing-whitespace)

              (goto-char 0)
              (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil)

              (make-local-variable 'space-trail-strip-whitespace-on-current-line)
              (setq space-trail-strip-whitespace-on-current-line t)

              (goto-line 3)
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (space-trail-test-next-trailing-whitespace) :to-be nil))

          (it "does not remove trailing space in Markdown code blocks."
              (markdown-mode)

              (insert "The following code block has an empty line:
    if () {
    
    }")

              (space-trail-maybe-delete-trailing-whitespace)
              (goto-char 0)

              (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil))

          (it "removes trailing space outside Markdown code blocks."
              (erase-buffer)
              (markdown-mode)
              (insert "The following text is only indented three spaces:
   foo
   
   bar")

              (goto-char 0)
              (space-trail-maybe-delete-trailing-whitespace)
              (expect (space-trail-test-next-trailing-whitespace) :to-be nil))

          ;; TODO Implement an opt-in to stripping inside strings.
          (it "removes trailing space inside strings unless asked not to."
            (erase-buffer)
            (emacs-lisp-mode)

            (insert "(foo \"This is a     \nstring with trailing spaces.\")")

            (space-trail-maybe-delete-trailing-whitespace)

            (goto-char 0)
            (expect (space-trail-test-next-trailing-whitespace) :to-be nil)

            (erase-buffer)

            (insert "(foo \"This is a     \nstring with trailing spaces.\")")

            (make-local-variable 'space-trail-strip-whitespace-in-strings)
            (setq space-trail-strip-whitespace-in-strings nil)

            (space-trail-maybe-delete-trailing-whitespace)

            (goto-char 0)
            (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil))

          )

;; Local Variables:
;; space-trail-strip-whitespace-in-strings: nil
;; End:

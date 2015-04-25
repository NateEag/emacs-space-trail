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

          ;; TODO Implement this feature (maybe - might only be useful in
          ;; early dev of space-trail, since the "don't strip inside strings"
          ;; feature hasn't been implemented yet).
          (xit "does not remove trailing space in opted-out buffers.")
          
          (it "removes trailing space on current line only if asked."
              (goto-line 3)
              (space-trail-maybe-delete-trailing-whitespace)

              (goto-char 0)
              (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil)

              ;; TODO Once a real deactivate mechanism is defined, use that.
              ;; This is a lame hack.
              (setq space-trail-prevent-line-stripping-predicates '())

              (goto-line 3)
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (space-trail-test-next-trailing-whitespace) :to-be nil)

              (setq space-trail-prevent-line-stripping-predicates
                    '(space-trail-point-on-line-p
                      space-trail-in-markdown-code-block-p
                      space-trail-in-string-p)))

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
          (it "removes trailing space inside strings only if asked."
            (erase-buffer)
            (emacs-lisp-mode)

            (insert "(foo \"This is a     \nstring with trailing spaces.\")")

            (space-trail-maybe-delete-trailing-whitespace)

            (goto-char 0)
            (expect (space-trail-test-next-trailing-whitespace) :not :to-be nil))

          )

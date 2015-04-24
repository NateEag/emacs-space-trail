(require 'markdown-mode)
(load-file "space-trail.el")

(describe "space-trail-maybe-delete-trailing-whitespace"
          (before-each
           (get-buffer-create "space-trail-test")
           (set-buffer "space-trail-test")

           (erase-buffer)
           (insert "This is a string
which has some trailing whitespace    ")
           (goto-char 0))

          (it "removes a buffer's trailing whitespace."
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (re-search-forward "\\s-$" nil t) :to-be nil))

          (it "does not remove trailing space in ignored modes."
              (diff-mode)
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (re-search-forward "\\s-$" nil t) :not :to-be nil)
              (fundamental-mode))

          (it "removes trailing space on current line only if asked."
              (goto-line 2)
              (space-trail-maybe-delete-trailing-whitespace)

              (goto-char 0)
              (expect (re-search-forward "\\s-$" nil t) :not :to-be nil)

              ;; TODO Find more readable way to remove function from list.
              (setq space-trail-prevent-line-stripping-predicates '())

              (goto-line 2)
              (space-trail-maybe-delete-trailing-whitespace)

              (expect (re-search-forward "\\s-$" nil t) :to-be nil))

          (it "does not remove trailing space in Markdown code blocks."
              (markdown-mode)

              (erase-buffer)
              (insert "The following code block has an empty line:
    if () {
    
    }")

              (space-trail-maybe-delete-trailing-whitespace)
              (expect (re-search-forward "\\s-$" nil t) :not :to-be nil))

          ;; TODO Implement this feature.
          (xit "removes trailing space inside strings only if asked.")

          )

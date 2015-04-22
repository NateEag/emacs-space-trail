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

          (it "does not remove trailing whitespace in ignored modes."
              (diff-mode)
              (space-trail-maybe-delete-trailing-whitespace)
              (message (buffer-string))

              (expect (re-search-forward "\\s-$" nil t) :not :to-be nil)))

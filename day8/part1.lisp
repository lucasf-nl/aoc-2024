;this is a comment
(ql:quickload "uiop")

(let ((input (uiop:read-file-lines "test.txt")))
    (dolist (item input)
        (print item)))

(quit)
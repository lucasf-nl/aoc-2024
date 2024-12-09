;this is a comment
(ql:quickload "uiop")

(defun read_input ()
    (let ((input (uiop:read-file-lines "test.txt")))
        (dolist (item input)
            (print item))))

(read_input)
(quit)
;;; init-clojure-cider.el --- Cider support for clojure -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'init-clojure)


(defun joker-fix-file ()
  (interactive)
  (message "joker --formt" (buffer-file-name))
  (shell-command (concat "joker --format --write " (buffer-file-name))))

(defun add-clj-format-before-save ()
  (interactive)
  (add-hook 'before-save-hook
            'cider-format-buffer
            t
            t)
  (add-hook 'before-save-hook
            'joker-fix-file
            t
            t))

(when (maybe-require-package 'cider)
  (setq nrepl-popup-stacktraces nil)

  (with-eval-after-load 'cider
    (add-hook 'cider-repl-mode-hook 'subword-mode)
    (add-hook 'cider-repl-mode-hook 'paredit-mode))

  (require-package 'flycheck-clojure)
  (with-eval-after-load 'clojure-mode
    (with-eval-after-load 'cider
      (with-eval-after-load 'flycheck
        (add-hook 'before-save-hook 'cider-format-buffer)
        (dolist (binding '("M-s"))
          (define-key cider-mode-map (read-kbd-macro binding)nil))))))


(provide 'init-clojure-cider)
;;; init-clojure-cider.el ends here

;;; init-clojure.el --- Clojure support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; See also init-clojure-cider.el



(defun flycheck-kondo-setup ()
  "Setup Flycheck for Clojure."
  (interactive)
  (dolist (checkers '((clj-kondo-clj . clojure-joker)
                      (clj-kondo-cljs . clojurescript-joker)
                      (clj-kondo-cljc . clojure-joker)
                      (clj-kondo-edn . edn-joker)))
    (flycheck-add-next-checker (car checkers) (cons 'error (cdr checkers)))))



(when (maybe-require-package 'clojure-mode)
  (require-package 'cljsbuild-mode)
  (require-package 'elein)
  (require-package 'flycheck-joker)
  (require-package 'flycheck-clj-kondo)

  (with-eval-after-load 'clojure-mode

    (add-hook 'clojure-mode-hook 'sanityinc/lisp-setup)
    (add-hook 'clojure-mode-hook 'flycheck-kondo-setup)
    (add-hook 'clojure-mode-hook 'subword-mode)))


(provide 'init-clojure)
;;; init-clojure.el ends here

;;; init-javascript.el --- Support for Javascript and derivatives -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(maybe-require-package 'json-mode)
(maybe-require-package 'js2-mode)
(maybe-require-package 'coffee-mode)
(maybe-require-package 'typescript-mode)
(maybe-require-package 'prettier-js)
;;(maybe-require-package 'company)
;;(maybe-require-package 'company-tern)

;;(add-to-list 'company-backends 'company-tern)

(add-hook 'js2-mode-hook (lambda ()
                           ;; (tern-mode)
                           ;; (company-mode)
                           (flycheck-mode)
                           (prettier-js-mode)))

;; Need to first remove from list if present, since elpa adds entries too, which
;; may be in an arbitrary order

(add-to-list 'auto-mode-alist '("\\.\\(js\\|es6\\)\\(\\.erb\\)?\\'" . js2-mode))

;; js2-mode

;; Change some defaults: customize them to override
(setq-default js2-bounce-indent-p nil)
(after-load 'js2-mode
  ;; Disable js2 mode's syntax error highlighting by default...
  (setq-default js2-mode-show-parse-errors nil
                js2-mode-show-strict-warnings nil)
  ;; ... but enable it if flycheck can't handle javascript
  (autoload 'flycheck-get-checker-for-buffer "flycheck")
  (defun sanityinc/enable-js2-checks-if-flycheck-inactive ()
    (unless (flycheck-get-checker-for-buffer)
      (flycheck-add-mode 'javascript-eslint 'js2-mode)
      (setq-local js2-mode-show-parse-errors t)
      (setq-local js2-mode-show-strict-warnings t)))

  (add-hook 'js2-mode-hook 'sanityinc/enable-js2-checks-if-flycheck-inactive)
  (flycheck-add-mode 'javascript-eslint 'js2-mode)
  (defun use-eslint-from-node-modules ()
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (eslint (and root
                        (expand-file-name "node_modules/eslint/bin/eslint.js"
                                          root))))
      (when (and eslint (file-executable-p eslint))
        (setq-local flycheck-javascript-eslint-executable eslint))))
  (add-hook 'flycheck-mode-hook 'use-eslint-from-node-modules)

  (add-hook 'js2-mode-hook (lambda () (setq mode-name "JS2")))

  (js2-imenu-extras-setup))

(setq-default js-indent-level 2)
;; In Emacs >= 25, the following is an alias for js-indent-level anyway
(setq-default js2-basic-offset 2)


(add-to-list 'interpreter-mode-alist (cons "node" 'js2-mode))



(when (and (executable-find "ag")
           (maybe-require-package 'xref-js2))
  (after-load 'js2-mode
    (define-key js2-mode-map (kbd "M-.") nil)
    (add-hook 'js2-mode-hook
              (lambda () (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))))



;;; Coffeescript

(after-load 'coffee-mode
  (setq-default coffee-js-mode 'js2-mode
                coffee-tab-width js-indent-level))

(when (fboundp 'coffee-mode)
  (add-to-list 'auto-mode-alist '("\\.coffee\\.erb\\'" . coffee-mode)))

;; ---------------------------------------------------------------------------
;; Run and interact with an inferior JS via js-comint.el
;; ---------------------------------------------------------------------------

(when (maybe-require-package 'js-comint)
  (setq js-comint-program-command "node")

  (defvar inferior-js-minor-mode-map (make-sparse-keymap))
  (define-key inferior-js-minor-mode-map "\C-x\C-e" 'js-send-last-sexp)
  (define-key inferior-js-minor-mode-map "\C-cb" 'js-send-buffer)

  (define-minor-mode inferior-js-keys-mode
    "Bindings for communicating with an inferior js interpreter."
    nil " InfJS" inferior-js-minor-mode-map)

  (dolist (hook '(js2-mode-hook js-mode-hook))
    (add-hook hook 'inferior-js-keys-mode)))

;; ---------------------------------------------------------------------------
;; Alternatively, use skewer-mode
;; ---------------------------------------------------------------------------

(when (maybe-require-package 'skewer-mode)
  (after-load 'skewer-mode
    (add-hook 'skewer-mode-hook
              (lambda () (inferior-js-keys-mode -1)))))



(when (maybe-require-package 'add-node-modules-path)
  (after-load 'typescript-mode
    (add-hook 'typescript-mode-hook 'add-node-modules-path))
  (after-load 'js2-mode
    (add-hook 'js2-mode-hook 'add-node-modules-path)))


(provide 'init-javascript)
;;; init-javascript.el ends here

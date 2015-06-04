(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(inhibit-startup-screen t)
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; MELPA PACKAGES
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line



;; prog-mode ##########################################

;; code folding minor-mode
(add-hook 'prog-mode-hook 'hs-minor-mode)
;; modify minor mode key: hs-toggle-hidding to C-=
(defun my-new-map ()
  "remap C-c @ C-c to C-=."
  (local-set-key (kbd "C-=") 'hs-toggle-hiding))
(add-hook 'hs-minor-mode-hook 'my-new-map)


;; python-mode ########################################

(add-hook 'python-mode-hook 'ac-anaconda-setup)
(add-hook 'python-mode-hook 'anaconda-mode)
;;(add-to-list 'auto-mode-alist '("\\.py\\'" . anaconda-mode))
(add-to-list 'auto-mode-alist '("\\.sage\\'" . python-mode))
;;(ac-set-trigger-key "TAB")

; #############################################
; To load python templates
; http://blog.ishans.info/2012/06/10/adding-a-template-for-new-python-files-in-emacs/
 
(add-hook 'find-file-hooks 'maybe-load-template)
(defun maybe-load-template ()
  (interactive)
  (when (and 
         (string-match "\\.py$" (buffer-file-name))
         (eq 1 (point-max)))
    (python-mode)
    (insert-file "~/.emacs.d/templates/template.py")
    )
  )

;; latex-mode #########################################
;; http://emacs.stackexchange.com/questions/5938/how-to-make-auto-complete-work-in-auctex-mode
 

(defun my-ac-latex-mode () ; add ac-sources for latex
  ;; yasnippet code 'optional', before auto-complete
  (require 'yasnippet)
  ;; auto-complete setup, sequence is important
  (require 'auto-complete)
  (add-to-list 'ac-modes 'latex-mode) ; beware of using 'LaTeX-mode instead
  (require 'ac-math) ; package should be installed first

   (setq ac-sources
         (append '(ac-source-math-unicode
           ac-source-math-latex
           ac-source-latex-commands)
                 ac-sources))
   (yas-global-mode 1)
   (ac-set-trigger-key "TAB")
   (global-auto-complete-mode t)

   (setq ac-math-unicode-in-math-p t)
   (ac-flyspell-workaround) ; fixes a known bug of delay due to flyspell (if it is there)
   (add-to-list 'ac-modes 'org-mode) ; auto-complete for org-mode (optional)
   (require 'auto-complete-config) ; should be after add-to-list 'ac-modes and hooks
   (ac-config-default)
   (setq ac-auto-start nil)            ; if t starts ac at startup automatically
   (setq ac-auto-show-menu t)
   )

(add-hook 'LaTeX-mode-hook 'my-ac-latex-mode)




(load-library "iso-transl")

;; fichier lisp pour tester et etendre emacs

;;(add-to-list 'load-path "~/.emacs.d/lisp/")

;(load "~/.emacs.d/lisp/test")
;(load "~/.emacs.d/lisp/macros")
;(load "~/.emacs.d/lisp/xah_brackets_insertion")

;;(autoload 'end1 "test titre" "description" t)










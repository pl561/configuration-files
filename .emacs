(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(custom-enabled-themes (quote (tango)))
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

(electric-pair-mode t)

(load-library "iso-transl") ;; handles circumflex

(setq scroll-step 1) ;; scrolling with kb line by line
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling


(global-set-key (kbd "<f7>") 'scroll-down-line)
(global-set-key (kbd "<f8>") 'scroll-up-line)

; indented newline above current line
(defun nl_prev_custom ()
  (interactive)
  (beginning-of-line)
  (newline)
  (previous-line)
  (indent-according-to-mode)
)
(global-set-key (kbd "M-p p") 'nl_prev_custom)

;indented newline below current line
(defun nl_next_custom ()
  (interactive)
  (end-of-line)
  (newline)
  (indent-according-to-mode)
)
(global-set-key (kbd "M-p n") 'nl_next_custom)


;; duplicate current line
(defun my_copy_line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
)
(global-set-key (kbd "\C-c\C-w") 'my_copy_line)

;; duplicate current line
(defun my_duplicate_line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (newline)
  (yank)
  (message "current line has been duplicated")
)
(global-set-key (kbd "\C-c\C-d") 'my_duplicate_line)

(global-auto-revert-mode t)
;; reload a modified file on disk in emacs buffer
(global-set-key (kbd "<f5>") (lambda ()
                                (interactive)
                                (revert-buffer t t t)
                                (message "buffer is reverted")))

;; reload coloration in emacs buffer
(global-set-key (kbd "<f6>") (lambda ()
                                (interactive)
                                (font-lock-fontify-block)
                                (message "Coloration refreshed in buffer.")))

;; change current buffer to another opened one
(global-set-key (kbd "<f11>") 'previous-buffer)
(global-set-key (kbd "<f12>") 'next-buffer)

;; switch between displayed buffers
(global-unset-key (kbd "M-j"))
(global-unset-key (kbd "M-k"))
(global-set-key (kbd "M-j") (lambda () (interactive) (other-window 1)))
(global-set-key (kbd "M-k") (lambda () (interactive) (other-window -1)))

; resize current buffer
(global-set-key (kbd "<C-up>") 'shrink-window)
(global-set-key (kbd "<C-down>") 'enlarge-window)
(global-set-key (kbd "<C-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)


;; custom moving forward/backward words
;; http://stackoverflow.com/questions/1771102/changing-emacs-forward-word-behaviour/1772365#1772365
(defun my-syntax-class (char)
  "Return ?s, ?w or ?p depending or whether CHAR is a white-space, word or punctuation character."
  (pcase (char-syntax char)
      (`?\s ?s)
      (`?w ?w)
      (`?_ ?w)
      (_ ?p)))

(defun my-forward-word (&optional arg)
  "Move point forward a word (simulate behavior of Far Manager's editor).
With prefix argument ARG, do it ARG times if positive, or move backwards ARG times if negative."
  (interactive "^p")
  (or arg (setq arg 1))
  (let* ((backward (< arg 0))
         (count (abs arg))
         (char-next
          (if backward 'char-before 'char-after))
         (skip-syntax
          (if backward 'skip-syntax-backward 'skip-syntax-forward))
         (skip-char
          (if backward 'backward-char 'forward-char))
         prev-char next-char)
    (while (> count 0)
      (setq next-char (funcall char-next))
      (loop
       (if (or                          ; skip one char at a time for whitespace,
            (eql next-char ?\n)         ; in order to stop on newlines
            (eql (char-syntax next-char) ?\s))
           (funcall skip-char)
         (funcall skip-syntax (char-to-string (char-syntax next-char))))
       (setq prev-char next-char)
       (setq next-char (funcall char-next))
       ;; (message (format "Prev: %c %c %c Next: %c %c %c"
       ;;                   prev-char (char-syntax prev-char) (my-syntax-class prev-char)
       ;;                   next-char (char-syntax next-char) (my-syntax-class next-char)))
       (when
           (or
            (eql prev-char ?\n)         ; stop on newlines
            (eql next-char ?\n)
            (and                        ; stop on word -> punctuation
             (eql (my-syntax-class prev-char) ?w)
             (eql (my-syntax-class next-char) ?p))
            (and                        ; stop on word -> whitespace
             this-command-keys-shift-translated ; when selecting
             (eql (my-syntax-class prev-char) ?w)
             (eql (my-syntax-class next-char) ?s))
            (and                        ; stop on whitespace -> non-whitespace
             (not backward)             ; when going forward
             (not this-command-keys-shift-translated) ; and not selecting
             (eql (my-syntax-class prev-char) ?s)
             (not (eql (my-syntax-class next-char) ?s)))
            (and                        ; stop on non-whitespace -> whitespace
             backward                   ; when going backward
             (not this-command-keys-shift-translated) ; and not selecting
             (not (eql (my-syntax-class prev-char) ?s))
             (eql (my-syntax-class next-char) ?s))
            )
         (return))
       )
      (setq count (1- count)))))

(defun delete-word (&optional arg)
  "Delete characters forward until encountering the end of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (my-forward-word arg) (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

(defun my-backward-word (&optional arg)
  (interactive "^p")
  (or arg (setq arg 1))
  (my-forward-word (- arg)))

;; custom M-f/M-b/M-d/M-backspace
;; (global-set-key (kbd "C-<left>") 'my-backward-word)
;; (global-set-key (kbd "C-<right>") 'my-forward-word)
;; (global-set-key (kbd "C-<delete>") 'delete-word)
;; (global-set-key (kbd "C-<backspace>") 'backward-delete-word)

;; (global-set-key (kbd "M-b") 'my-backward-word)
;; (global-set-key (kbd "M-f") 'my-forward-word)
;; (global-set-key (kbd "M-d") 'delete-word)
;; (global-set-key (kbd "M-<backspace>") 'backward-delete-word)

;; (highlight-current-line-minor-mode t)
;; (highlight-indentation-mode t)
;; (setq cursor-type 'bar)
;; (set-face-background 'highlight-current-line-face "gray10")
;; global-hl-line-mode

;; ATOM THEME
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/atom-one-dark-theme/")
(load-theme 'atom-one-dark t)

;; MELPA PACKAGES
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line


;; snippets expansion with yasnippet
(yas-global-mode 1)

;; general
(require 'auto-complete-config)
(ac-config-default)
(setq ac-auto-show-menu (* ac-delay 1))
(global-set-key (kbd "<tab>") 'ac-start)

;; prog-mode ##########################################

;; (add-hook 'prog-mode-hook 'highlight-current-line-minor-mode)
;; (add-hook 'prog-mode-hook 'highlight-indentation-mode)
(setq cursor-type 'bar)
;;(setq cursor-type "red")
;; (set-cursor-color "red")

;;(setq highlight-current-line-set-bg-color "gray10")

;; code folding minor-mode
(add-hook 'prog-mode-hook 'hs-minor-mode)
;; modify minor mode key: hs-toggle-hidding to C-=
(defun my-new-map ()
  (local-set-key (kbd "C-+") 'hs-hide-all)
  "remap C-c @ C-c to C-=."
  (local-set-key (kbd "C-=") 'hs-toggle-hiding))
(add-hook 'hs-minor-mode-hook 'my-new-map)

;; octave-mode ########################################
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))

(add-hook 'octave-mode-hook
          (lambda ()
            (abbrev-mode 1)
            (auto-fill-mode 1)
            (if (eq window-system 'x)
                (font-lock-mode 1))))

;; python-mode ########################################

(require 'flycheck-pyflakes)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-to-list 'flycheck-disabled-checkers 'python-flake8)
(add-to-list 'flycheck-disabled-checkers 'python-pylint)

(add-hook 'python-mode-hook 'ac-anaconda-setup)
(add-hook 'python-mode-hook 'anaconda-mode)

(defun my-ac-custom ()
  (ac-auto-start nil)
  (local-set-key (kbd "TAB") 'ac-start)
)
;(add-hook 'python-mode-hook 'my-ac-custom)

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

;; fichier lisp pour tester et etendre emacs

;;(add-to-list 'load-path "~/.emacs.d/lisp/")

;(load "~/.emacs.d/lisp/test")
;(load "~/.emacs.d/lisp/macros")
;(load "~/.emacs.d/lisp/xah_brackets_insertion")

;;(autoload 'end1 "test titre" "description" t)



(defun xah-insert-bracket-pair (φleft-bracket φright-bracket)
  "Wrap or Insert a matching bracket and place cursor in between. If there's a text selection, wrap brackets around it. Else, smartly decide wrap or insert. (basically, if there's no char after cursor, just insert bracket pair.) φleft-bracket ＆ φright-bracket are strings. URL `http://ergoemacs.org/emacs/elisp_insert_brackets_by_pair.html' Version 2015-04-19"
  (if (use-region-p)
      (progn
        (let (
              (ξp1 (region-beginning))
              (ξp2 (region-end)))
          (goto-char ξp2)
          (insert φright-bracket)
          (goto-char ξp1)
          (insert φleft-bracket)
          (goto-char (+ ξp2 2))))
    (progn ; no text selection
      (if
          (or
           (looking-at "[^-_[:alnum:]]")
           (eq (point) (point-max)))
          (progn
            (insert φleft-bracket φright-bracket)
            (search-backward φright-bracket ))
        (progn
          (let (ξp1 ξp2)
            ;; basically, want all alphanumeric, plus hyphen and underscore, but don't want space or punctuations. Also want chinese.
            ;; 我有一帘幽梦，不知与谁能共。多少秘密在其中，欲诉无人能懂。
            (skip-chars-backward "-_[:alnum:]")
            (setq ξp1 (point))
            (skip-chars-forward "-_[:alnum:]")
            (setq ξp2 (point))
            (goto-char ξp2)
            (insert φright-bracket)
            (goto-char ξp1)
            (insert φleft-bracket)
            (goto-char (+ ξp2 (length φleft-bracket)))))))))


(defun xah-insert-paren () (interactive) (xah-insert-bracket-pair "(" ")") )
(defun xah-insert-bracket () (interactive) (xah-insert-bracket-pair "[" "]") )
(defun xah-insert-brace () (interactive) (xah-insert-bracket-pair "{" "}") )
(defun xah-insert-greater-less () (interactive) (xah-insert-bracket-pair "<" ">") )
(defun xah-insert-double-quotes () (interactive) (xah-insert-bracket-pair "\"" "\"") )
(defun xah-insert-simple-quotes () (interactive) (xah-insert-bracket-pair "\'" "\'") )

(global-set-key (kbd "M-p (") 'xah-insert-paren)
(global-set-key (kbd "M-p [") 'xah-insert-bracket)
(global-set-key (kbd "M-p {") 'xah-insert-brace)
(global-set-key (kbd "M-p <") 'xah-insert-greater-less)
(global-set-key (kbd "M-p \"") 'xah-insert-double-quotes)
(global-set-key (kbd "M-p \'") 'xah-insert-simple-quotes)




;; execute python file in emacs shell

(defun xah-run-current-file ()
  "Execute the current file.
For example, if the current buffer is the file xx.py, then it'll call 「python xx.py」 in a shell.
The file can be php, perl, python, ruby, javascript, bash, ocaml, vb, elisp.
File suffix is used to determine what program to run.

If the file is modified, ask if you want to save first.

URL `http://ergoemacs.org/emacs/elisp_run_current_file.html'
version 2014-10-28"
  (interactive)
  (let* (
         (ξsuffixMap
          ;; (‹extension› . ‹shell program name›)
          `(
            ("php" . "php")
            ("pl" . "perl")
            ("py" . "python")
            ;("py3" . ,(if (string-equal system-type "windows-nt") "c:/Python32/python.exe" "python3"))
            ("rb" . "ruby")
            ("sh" . "bash")
            ;("clj" . "java -cp /home/xah/apps/clojure-1.6.0/clojure-1.6.0.jar clojure.main")
            ("ml" . "ocaml")
            ("vbs" . "cscript")
            ))
         (ξfName (buffer-file-name))
         (ξfSuffix (file-name-extension ξfName))
         (ξprogName (cdr (assoc ξfSuffix ξsuffixMap)))
         (ξcmdStr (concat ξprogName " \""   ξfName "\"")))

    (when (buffer-modified-p)
      (when (y-or-n-p "Buffer modified. Do you want to save first?")
        (save-buffer)))

    (if (string-equal ξfSuffix "el") ; special case for emacs lisp
        (load ξfName)
      (if ξprogName
          (progn
            (message "Running…")
	    ;(message ξcmdStr)
            (shell-command ξcmdStr "*xah-run-current-file output*" ))
	    ;(shell-command ξcmdStr "*terminal*" ))
        (message "No recognized program file suffix for this file.")))))

(global-set-key (kbd "<C-return>") 'xah-run-current-file)

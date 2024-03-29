					; ================= PACKAGE MANAGEMENT ================

(require 'package)

(setq package-list '(multiple-cursors
		     tide
		     flycheck
		     helm
		     helm-lsp
		     lsp-eslint
		     dap-mode
		     yasnippet
		     use-package
		     lsp-treemacs
		     ))

; list the repositories containing them

(add-to-list 'package-archives
        '("melpa-stable" . "http://stable.melpa.org/packages/"))
    
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))



; activate all the packages (in particular autoloads)
(package-initialize)

; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))
					; ================= OS =======================
(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(delete-selection-mode t)
(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-minimum-prefix-length 1
      lsp-lens-enable t
      lsp-signature-auto-activate nil
      ; lsp-enable-indentation nil ; uncomment to use cider indentation instead of lsp
      ; lsp-enable-completion-at-point nil ; uncomment to use cider completion instead of lsp
      )

                                        ; ================= Emacs Boot  ================
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
	(setq dashboard-banner-logo-title "Happy Hacking!")
	(setq dashboard-items '((recents  . 5)										   (projects . 10)
				 (bookmarks . 10))))


(setq inhibit-startup-message t)

																				; ================= UI  ================


																				; https://www.jetbrains.com/lp/mono/
																				; https://linuxconfig.org/how-to-install-and-manage-fonts-on-linux
(add-to-list 'default-frame-alist '(font . "JetBrains Mono"))
(add-to-list 'default-frame-alist '(line-spacing . 0.1))
(set-face-attribute 'default nil :height 100)

(use-package dracula-theme
  :ensure t
  :config (load-theme 'dracula t))


(if window-system
    (tool-bar-mode -1))

(menu-bar-mode -1)


																				; ================= GLOBAL EDITOR  ================
  
(set-default 'cursor-type 'bar)

;; scroll one line at a time (less "jumpy" than defaults)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time

(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-step 1) ;; keyboard scroll one line at a time

(global-set-key (kbd "C-n") 'treemacs)

(require 'rainbow-delimiters)

(setq custom-tab-width 1)
;; Two callable functions for enabling/disabling tabs in Emacs
(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs  ()
  (local-set-key (kbd "TAB") 'tab-to-tab-stop)
  ;(setq indent-tabs-mode t)
  (setq tab-width custom-tab-width))

(global-set-key (kbd "C-/") 'comment-or-uncomment-region)

;; get keybinding of function: C-h w <function name>


(use-package expand-region
  :ensure t
  :bind (("C-q" . er/expand-region)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-M-<mouse-1>" . mc/add-cursor-on-click)))

(use-package helm-ag
  :ensure t)

;; search window
(helm-mode)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)


(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; company
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)

(use-package company
  :ensure t
  :config (global-company-mode t))

																				; ================= CODING  ================
;; CL 
;; sbcl --eval '(ql:quickload :quicklisp-slime-helper)' --quit
(load (expand-file-name "~/.quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")
(add-to-list 'slime-contribs 'slime-repl)
(add-to-list 'auto-mode-alist '("\\.cl\\'" . common-lisp-mode))
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'common-lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'common-lisp-mode-hook             #'rainbow-delimiters-mode-enable)

(defvar slime-repl-font-lock-keywords lisp-font-lock-keywords-2)
(defun slime-repl-font-lock-setup ()
  (setq font-lock-defaults
        '(slime-repl-font-lock-keywords
         ;; From lisp-mode.el
         nil nil (("+-*/.<>=!?$%_&~^:@" . "w")) nil
         (font-lock-syntactic-face-function
         . lisp-font-lock-syntactic-face-function))))

(defadvice slime-repl-insert-prompt (after font-lock-face activate)
  (let ((inhibit-read-only t))
    (add-text-properties
     slime-repl-prompt-start-mark (point)
     '(font-lock-face
      slime-repl-prompt-face
      rear-nonsticky
      (slime-repl-prompt read-only font-lock-face intangible)))))

(defun slime-describe-symbol-keys ()
  (local-set-key (kbd "C-?") 'slime-describe-symbol))

(add-hook 'slime-mode-hook #'slime-describe-symqbol-keys)
(add-hook 'slime-mode-hook #'rainbow-delimiters-mode)

(add-hook 'slime-repl-mode-hook #'slime-repl-font-lock-setup)
(add-hook 'slime-repl-mode-hook #'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook #'rainbow-delimiters-mode-enable)
(add-hook 'slime-repl-mode-hook #'slime-describe-symbol-keys)
(add-hook 'slime-repl-mode-hook #'rainbow-delimiters-mode)

(slime-setup '(slime-fancy slime-quicklisp slime-asdf slime-company))


;; ClOJURE
(use-package cider
  :ensure t
  :pin melpa-stable)

(add-hook 'clojure-mode-hook 'lsp)
(add-hook 'clojurescript-mode-hook 'lsp)
(add-hook 'clojurec-mode-hook 'lsp)

;; WEB
(use-package jest-test-mode 
  :ensure t 
  :commands jest-test-mode
  :hook (lsp-mode js-mode typescript-tsx-mode))

(use-package projectile
	:ensure t
	:config (projectile-mode +1))

(lsp-treemacs-sync-mode 1)

(global-set-key (kbd "C-f") 'project-find-file)
(global-set-key (kbd "C-a") 'helm-ag-project-root)
(global-set-key (kbd "C-c C-c") 'lsp-eslint-fix-all)
(global-set-key (kbd "M-RET") 'helm-lsp-code-actions)

;; magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;; json-mode
(use-package json-mode
  :ensure t)

(use-package web-mode
  :ensure t
  :mode (("\\.js\\'" . web-mode)
	 ("\\.jsx\\'" .  web-mode)
	 ("\\.ts\\'" . web-mode)
	 ("\\.tsx\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :commands web-mode)

(setq electric-indent-mode -1)
(setq electric-indent-inhibit t)
(setq-default tab-width 1)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 2)
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))
;; lsp-mode
(setq lsp-log-io nil) ;; Don't log everything = speed
(setq lsp-keymap-prefix "C-c l")
(setq lsp-restart 'auto-restart)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-sideline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)

(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-eslint-auto-fix-on-save t)

;  (setq lsp-eslint-enable t)
	(setq lsp-enable-on-type-formatting nil)
	(setq lsp-enable-indentation nil)
	(setq lsp-typescript-format-enable nil)
; (setq indent-tabs-mode t)
	:hook ((web-mode . lsp-deferred)
	       (lsp-mode . lsp-enable-which-key-integration)
	       (lsp-mode . lsp-eslint)
        (lsp-mode . show-paren-mode))
	:commands lsp-deferred)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (slime-company ac-slime auto-complete paredit slime cider jest-test-mode projectile helm-ag dap-firefox yasnippet which-key web-mode use-package tide multiple-cursors magit lsp-ui json-mode helm-lsp expand-region exec-path-from-shell dracula-theme dap-mode company))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

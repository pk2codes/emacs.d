					; ================= PACKAGE MANAGEMENT ================

(require 'package)

(setq package-list '(multiple-cursors
		     tide
		     flycheck
		     helm
		     helm-lsp
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
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)
(global-display-line-numbers-mode)

                                        ; ================= Emacs Boot  ================
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
	(setq dashboard-banner-logo-title "Happy Hacking!")
	(setq dashboard-items '((recents  . 5)
													(projects . 10)
													(bookmarks . 10))))


(setq inhibit-startup-message t)

																				; ================= UI  ================
(use-package dracula-theme
  :ensure t
  :config (load-theme 'dracula t))


(if window-system
    (tool-bar-mode -1))

(menu-bar-mode -1)


																				; ================= GLOBAL EDITOR  ================

(setq-default tab-width 2) ; emacs 23.1 to 26 default to 8
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
(use-package projectile
	:ensure t
	:config (projectile-mode +1))

(lsp-treemacs-sync-mode 1)

(global-set-key (kbd "C-f") 'project-find-file)
(global-set-key (kbd "C-a") 'helm-ag-project-root)
(global-set-key (kbd "C-c C-c") 'lsp-eslint-fix-all)

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
  (setq lsp-eslint-enable t)
  :hook ((web-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration)
         (lsp-mode . lsp-eslint))
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
		(projectile helm-ag dap-firefox yasnippet which-key web-mode use-package tide multiple-cursors magit lsp-ui json-mode helm-lsp expand-region exec-path-from-shell dracula-theme dap-mode company))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

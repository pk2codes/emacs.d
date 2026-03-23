
;; Native Compilation Warnings stumm schalten
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors 'silent)
  (setq native-comp-deferred-compilation t)
  (setq native-compile-prune-cache t))



					; ================= PACKAGE MANAGEMENT ================



(require 'package)

(setq package-archives
      '(("gnu"          . "https://elpa.gnu.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa"        . "https://melpa.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))


;; ================= NATIVE COMPILATION ==============
(setq inhibit-automatic-native-compilation t)
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors 'silent)
  (setq native-comp-jit-compilation nil))



(setq warning-minimum-level :error)
;; *Warnings* Buffer nicht automatisch anzeigen

;; Auto-install alle benötigten Pakete
(setq package-list '(
                     powershell
                     multiple-cursors
                     tide
                     flycheck
                     helm
                     helm-lsp
                     dap-mode
                     yasnippet
                     use-package
                     lsp-treemacs
                     slime
                     slime-company
                     paredit
                     rainbow-delimiters
                     cider
                     dashboard
                     dracula-theme
                     expand-region
                     treemacs
                     lsp-mode
                     lsp-ui
                     company
                     magit
                     json-mode
                     web-mode
                     projectile
                     which-key
                     exec-path-from-shell
                     helm-rg
		     jest-test-mode))

;; <-- DAS fehlte: tatsächliche Installationsschleife
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

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
      lsp-signature-auto-activate nil)

; ================= Emacs Boot ================
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Happy Hacking!")
  (setq dashboard-items '((recents   . 5)
                          (projects  . 10)
                          (bookmarks . 10))))

(setq inhibit-startup-message t)

; ================= UI ================
(if (find-font (font-spec :name "JetBrains Mono"))
    (progn
      (add-to-list 'default-frame-alist '(font . "JetBrains Mono"))
      (set-face-attribute 'default nil :height 100))
  (message "WARNING: Font 'JetBrains Mono' not found."))

(add-to-list 'default-frame-alist '(line-spacing . 0.1))

(use-package dracula-theme
  :ensure t
  :config (load-theme 'dracula t))

(when window-system
  (tool-bar-mode -1))
(menu-bar-mode -1)

; ================= GLOBAL EDITOR ================

(set-default 'cursor-type 'bar)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse t)
(setq scroll-step 1)

(global-set-key (kbd "C-n") 'treemacs)

(require 'rainbow-delimiters)

(setq custom-tab-width 2)
(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs ()
  (local-set-key (kbd "TAB") 'tab-to-tab-stop)
  (setq tab-width custom-tab-width))

(global-set-key (kbd "C-/") 'comment-or-uncomment-region)

(use-package expand-region
  :ensure t
  :bind (("C-q" . er/expand-region)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-M-<mouse-1>" . mc/add-cursor-on-click)))

(use-package helm-rg
  :ensure t)

(helm-mode)
(define-key global-map [remap find-file]                #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer]         #'helm-mini)

(use-package which-key
  :ensure t
  :config (which-key-mode))

(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)

(use-package company
  :ensure t
  :config (global-company-mode t))

; ================= CODING ================

;; CL / SLIME
;; sbcl --eval '(ql:quickload :quicklisp-slime-helper)' --quit
(let ((slime-helper (expand-file-name "~/.quicklisp/slime-helper.el")))
  (if (file-exists-p slime-helper)
      (load slime-helper)
    (message "WARNING: Quicklisp slime-helper not found. Run: sbcl --eval '(ql:quickload :quicklisp-slime-helper)' --quit")))

(setq inferior-lisp-program "sbcl")
(add-to-list 'auto-mode-alist '("\\.cl\\'" . common-lisp-mode))

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook  #'enable-paredit-mode)
(add-hook 'lisp-mode-hook        #'enable-paredit-mode)
(add-hook 'common-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'common-lisp-mode-hook #'rainbow-delimiters-mode-enable)

(defvar slime-repl-font-lock-keywords lisp-font-lock-keywords-2)
(defun slime-repl-font-lock-setup ()
  (setq font-lock-defaults
        '(slime-repl-font-lock-keywords
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

;; Typo-Fix: symqbol -> symbol
(add-hook 'slime-mode-hook #'slime-describe-symbol-keys)
(add-hook 'slime-mode-hook #'rainbow-delimiters-mode)

(add-hook 'slime-repl-mode-hook #'slime-repl-font-lock-setup)
(add-hook 'slime-repl-mode-hook #'enable-paredit-mode)
(add-hook 'slime-repl-mode-hook #'rainbow-delimiters-mode-enable)
(add-hook 'slime-repl-mode-hook #'slime-describe-symbol-keys)
(add-hook 'slime-repl-mode-hook #'rainbow-delimiters-mode)

(when (package-installed-p 'slime-company)
  (slime-setup '(slime-fancy slime-quicklisp slime-asdf slime-company)))

;; CLOJURE
(use-package cider
  :ensure t
  :pin melpa-stable)

(add-hook 'clojure-mode-hook       'lsp)
(add-hook 'clojurescript-mode-hook 'lsp)
(add-hook 'clojurec-mode-hook      'lsp)
;; WINDOWS
(use-package powershell
  :ensure t)



;; WEB
(use-package jest-test-mode
  :ensure t
  :commands jest-test-mode
  :hook (lsp-mode js-mode typescript-tsx-mode))

(use-package projectile
  :ensure t
  :config (projectile-mode +1))

(lsp-treemacs-sync-mode 1)

(global-set-key (kbd "C-f")     'project-find-file)
(global-set-key (kbd "C-a")     'helm-rg)          ;; <-- Klammer-Typo behoben
(global-set-key (kbd "C-c C-c") 'lsp-eslint-fix-all)
(global-set-key (kbd "M-RET")   'helm-lsp-code-actions)

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package json-mode
  :ensure t)

(use-package web-mode
  :ensure t
  :mode (("\\.js\\'"   . web-mode)
         ("\\.jsx\\'"  . web-mode)
         ("\\.ts\\'"   . web-mode)
         ("\\.tsx\\'"  . web-mode)
         ("\\.html\\'" . web-mode))
  :commands web-mode)

(setq electric-indent-inhibit t)
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 2)
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

(setq lsp-log-io nil)
(setq lsp-keymap-prefix "C-c l")
(setq lsp-restart 'auto-restart)
(setq lsp-ui-sideline-show-diagnostics t)
(setq lsp-ui-sideline-show-hover t)
(setq lsp-ui-sideline-show-code-actions t)

(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-eslint-auto-fix-on-save t)
  (setq lsp-enable-on-type-formatting nil)
  (setq lsp-enable-indentation nil)
  (setq lsp-typescript-format-enable nil)
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
   '(slime-company paredit slime cider jest-test-mode projectile helm-rg yasnippet which-key web-mode use-package tide multiple-cursors magit lsp-ui json-mode helm-lsp expand-region exec-path-from-shell dracula-theme dap-mode company rainbow-delimiters dashboard treemacs lsp-mode lsp-treemacs)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

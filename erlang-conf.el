(use-package erlang
  :init
  (add-to-list 'auto-mode-alist '("\\.P\\'" . erlang-mode))
  (add-to-list 'auto-mode-alist '("\\.E\\'" . erlang-mode))
  (add-to-list 'auto-mode-alist '("\\.S\\'" . erlang-mode))
  (add-to-list 'auto-mode-alist '("rebar\\.config$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("relx\\.config$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("system\\.config$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("rebar\\.lock$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("\\.app\\.src$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("\\.erl?$" . erlang-mode))
  (add-to-list 'auto-mode-alist '("\\.hrl?$" . erlang-mode))

  (add-hook 'after-init-hook 'erlang/after-init-hook)
  (defun erlang/after-init-hook ()
    ;(require 'edts-start)
    )

  (defun erlang/open-shell ()
    (interactive)
    (erlang-shell))
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  :config
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (setq erlang-electric-commands '(erlang-electric-comma erlang-electric-semicolon))
  (setq erlang-indent-level 2)
  (setq inferior-erlang-machine "rebar3")
  (setq inferior-erlang-machine-options '("shell"))
  (setq inferior-erlang-shell-type nil)
  
  (setq flycheck-erlang-include-path '("../include" "../deps"))

  (require 'ivy-erlang-complete)
  
  (defun fix-erlang-project-includes (project-root)
    "Find erlang include paths for PROJECT-ROOT with project deps."
    (setq-local flycheck-erlang-include-path
                (append
                 (s-split
                  "\n"
                  (shell-command-to-string
                   (concat "find "
                           project-root
                           "/*"
                           " -type d -name include"))
                  t)
                 (list project-root
                       (concat project-root "/include")
                       (concat project-root "/deps")
                       default-directory
                       (concat
                        (locate-dominating-file
                         default-directory
                         "src") "include")
                       (concat
                        (locate-dominating-file
                         default-directory
                         "src") "deps")))))

  (defun fix-erlang-project-code-path (project-root)
    "Find erlang include paths for PROJECT-ROOT with project deps."
    (let ((code-path
           (split-string (shell-command-to-string
                          (concat "find " project-root " -type d -name ebin")))
           ))
      (setq-local flycheck-erlang-library-path code-path)))

  (defun setup-ivy-erlang-complete ()
    "Setup for erlang."
    (let ((project-root (ivy-erlang-complete-autosetup-project-root)))
      (fix-erlang-project-code-path project-root)
      (fix-erlang-project-includes project-root))
    (ivy-erlang-complete-init))


  (defun bindings ()
    (local-set-key (kbd "C-c TAB") #'auto-complete)
    (local-set-key (kbd "C-c SPC") #'ac-complete-with-helm)
    (local-set-key (kbd "C-c M-r") #'erlang/open-shell)
    (local-set-key (kbd "C-c C-c") #'makefile-compile)
    (local-set-key (kbd "C-c C-t") #'makefile-test)
    (local-set-key (kbd "C-c d")   #'edts-show-doc-under-point)
    (local-set-key (kbd "C-c e")   #'edts-mode)
    (local-set-key (kbd "M-e")     #'end-of-line))

  (defun setup-erlang-flycheck ()
    (setq-local flycheck-display-errors-function nil)
    (setq-local flycheck-erlang-include-path '("../include" ))
    (setq-local flycheck-erlang-library-path '("../src" "../test"))
    (setq-local flycheck-check-syntax-automatically '(save))
    (setq erlang-root-dir "~/.kerl/19.3/")
    (flycheck-rebar3-setup)
    (flycheck-mode 1)
    (flycheck-popup-tip-mode 1))

  (defun mh-simple-get-deps-include-dirs ()
    (list "../include"))

  (defun setup-erlang-flymake ()
     (setq-local load-path (cons  "~/.kerl/19.3/lib/tools-2.9.1/emacs/"
                         load-path))
     (setq-local erlang-root-dir "~/.kerl/19.3/")
     (setq-local exec-path (cons "~/.kerl/19.3/bin" exec-path))
     (setq-local erlang-flymake-get-include-dirs-function 'mh-simple-get-deps-include-dirs)
     (require 'erlang-start)
     (require 'erlang-flymake)
     (erlang-flymake-only-on-save)
     (flymake-mode-on)
     (flymake-cursor-mode 1))

  (defun erlang-mode-conf ()
    (auto-complete-mode 1)
    (indent-guide-mode 1)
    (smartparens-strict-mode 1)
    (setq-local indent-tabs-mode nil)
    (bindings)
    (setup-erlang-flymake))

  (defun erlang-shell-mode-conf ()
    (bindings))

  (add-hook 'erlang-mode-hook (lambda () (run-hooks 'prog-mode-hook)))
  (add-hook 'erlang-mode-hook #'erlang-mode-conf)
  (add-hook 'erlang-shell-mode-hook #'erlang-shell-mode-conf)
  (add-hook 'edts-shell-mode-hook #'erlang-shell-mode-conf)

  :mode
  ("\\.erl\\'" . erlang-mode)
  ("\\.hrl\\'" . erlang-mode)
  :ensure t)


(use-package edts
  :init
  ;; wget -c http://erlang.org/download/otp_doc_man_20.2.tar.gz
  ;; mkdir -p ~/.emacs.d/edts/doc/20.2
  ;; tar xzf otp_doc_man_20.2.tar.gz -C  ~/.emacs.d/edts/doc/20.2
  (setq edts-inhibit-package-check t
        edts-man-root "~/.emacs.d/edts/doc/20.2")
  :config
  (defun edts-show-tooltip (x)
    (if x (popup-tip x)  (message "can't find doc")))
  :ensure t)

(use-package neotree
  :config
  (require 'neotree)
  (mapcar (lambda (x) (add-to-list 'neo-hidden-regexp-list x))
          '("\\.beam$"))
  :ensure t)

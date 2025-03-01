<!-- ---
!-- Timestamp: 2025-03-01 20:00:09
!-- Author: ywatanabe
!-- File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-spinner/README.md
!-- --- -->

# Emacs Spinner

[![Build Status](https://github.com/ywatanabe1989/emacs-spinner/workflows/tests/badge.svg)](https://github.com/ywatanabe1989/emacs-spinner/actions)

A lightweight spinner animation implementation for Emacs. This package provides a simple way to show an animated spinner in Emacs buffers, which is useful for indicating background processes or loading states.

## Features

- Simple API to start and stop spinners
- Customizable spinner frames
- Place spinners at any position in any buffer
- Track and manage multiple spinners
- Unicode-based spinner animation

## Installation

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/emacs-spinner.git ~/.emacs.d/lisp/emacs-spinner
   ```

2. Add to your Emacs configuration:
   ```elisp
   (add-to-list 'load-path "~/.emacs.d/lisp/emacs-spinner")
   (require 'emacs-spinner)
   ```

### Using use-package

```elisp
(use-package emacs-spinner
  :load-path "~/.emacs.d/lisp/emacs-spinner")
```

## Usage

### Basic Usage

Start a spinner at the current position:

```elisp
;; Start spinner at current point
(emacs-spinner-start)

;; When done, stop the spinner
(emacs-spinner-stop)
```

### Advanced Usage

```elisp
;; Set position for spinner
(setq my-position (emacs-spinner-set-position))

;; Start spinner at set position
(emacs-spinner-start my-position)

;; Track a specific spinner
(setq my-spinner-id (emacs-spinner-start))
(emacs-spinner-stop my-spinner-id)

;; Start spinner in a different buffer at a specific position
(emacs-spinner-start (cons some-buffer some-position))

;; Stop all spinners
(emacs-spinner-stop-all)
```

## Customization

You can customize the spinner appearance by changing the `emacs-spinner-frames` variable:

```elisp
(emacs-spinner-set-frames '("-" "\\" "|" "/"))
(emacs-spinner-set-frames '("⠋" "⠙" "⠸" "⢰" "⣠" "⣄" "⡆" "⠇"))
(emacs-spinner-set-frames '("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"))
(emacs-spinner-set-frames '("•" "○" "◎" "●" "◎" "○"))
(emacs-spinner-set-frames '("🕛" "🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚"))
(emacs-spinner-set-frames '("🌑" "🌒" "🌓" "🌔" "🌕" "🌖" "🌗" "🌘"))
(emacs-spinner-set-frames '("💓" "💗" "💓" "💖"))
(emacs-spinner-set-frames '("♩" "♪" "♫" "♬"))

;; ;; Start the spinner at current position
;; (emacs-spinner-start)
;; (emacs-spinner-stop)
```

## Contact
Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)

<!-- EOF -->
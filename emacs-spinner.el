;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-03-01 21:19:42>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-spinner/emacs-spinner.el

;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-03-01 21:15:50>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-spinner/emacs-spinner.el
;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-03-01 21:10:56>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-spinner/emacs-spinner.el
;;; emacs-spinner.el --- A spinner implementation for Emacs -*- lexical-binding: t -*-
;; Author: ywatanabe
;; Version: 1.0
;; Keywords: progress, spinner
;;; Commentary:
;; A lightweight spinner animation implementation for Emacs
;;; Code:

(defvar emacs-spinner-frames
  '("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  "Frames for the spinner animation.")

(defvar --emacs-spinner-timer nil
  "Timer for the spinner animation.")

(defvar --emacs-spinner-index 0
  "Current index in the spinner animation.")

(defvar --emacs-spinner-marker nil
  "Marker for spinner position.")

(defvar --emacs-spinner-active-timers nil
  "List of all active spinner timers.")

(defun emacs-spinner-set-frames
    (frames)
  "Safely change the spinner animation FRAMES.
Will restart any active spinners with the new frames."
  (interactive)
  (let
      ((active-spinners
        (copy-sequence --emacs-spinner-active-timers))
       (was-active
        (and --emacs-spinner-timer
             (memq --emacs-spinner-timer --emacs-spinner-active-timers))))
    ;; Stop all spinners
    (emacs-spinner-stop-all)
    ;; Set new frames
    (setq emacs-spinner-frames frames)
    ;; Reset index
    (setq --emacs-spinner-index 0)
    ;; Restart the global spinner if it was active
    (when was-active
      (emacs-spinner-start))))

(defun emacs-spinner-set-position
    (&optional buffer position)
  "Set spinner position in BUFFER at POSITION.
POSITION can be a marker or a point.
If BUFFER is nil, use current buffer.
If POSITION is nil, use current point."
  (let
      ((buf
        (or buffer
            (current-buffer))))
    (with-current-buffer buf
      (let
          ((pos
            (cond
             ((null position)
              (point))
             ((markerp position)
              position)
             (t position))))
        ;; Create marker at specified position
        (setq --emacs-spinner-marker
              (copy-marker pos))
        ;; Make it stay fixed relative to text
        (set-marker-insertion-type --emacs-spinner-marker nil)
        ;; Return a cons cell that emacs-spinner-start can use
        (cons buf pos)))))

(defun emacs-spinner-start
    (&optional buffer-and-position)
  "Start the spinner animation at specified location.
BUFFER-AND-POSITION can be:
- nil: use current buffer and point
- cons cell (BUFFER . POSITION): use specified buffer and position
- BUFFER: use specified buffer and current point in that buffer
Returns the timer object that can be used to identify this spinner."
  (let*
      ((buf
        (cond
         ((null buffer-and-position)
          (current-buffer))
         ((consp buffer-and-position)
          (car buffer-and-position))
         (t buffer-and-position)))
       (pos
        (cond
         ((null buffer-and-position)
          nil)
         ((consp buffer-and-position)
          (cdr buffer-and-position))
         (t nil))))
    (when
        (and
         (buffer-live-p buf)
         (not --emacs-spinner-timer))
      ;; Set position with our buffer and position
      (emacs-spinner-set-position buf pos)
      ;; Add placeholder text at the marker position
      (with-current-buffer
          (marker-buffer --emacs-spinner-marker)
        (save-excursion
          (goto-char --emacs-spinner-marker)
          ;; Add a space character as placeholder for spinner
          (insert " ")))
      ;; Start animation timer
      (setq --emacs-spinner-timer
            (run-with-timer 0 0.1
                            (lambda
                              ()
                              (when
                                  (and --emacs-spinner-marker
                                       (marker-buffer --emacs-spinner-marker))
                                (condition-case nil
                                    (with-current-buffer
                                        (marker-buffer --emacs-spinner-marker)
                                      (save-excursion
                                        (let
                                            ((pos
                                              (marker-position --emacs-spinner-marker)))
                                          ;; Replace placeholder with current frame
                                          (goto-char pos)
                                          (delete-char 1)
                                          (insert
                                           (propertize
                                            (nth --emacs-spinner-index emacs-spinner-frames)
                                            'face
                                            '(:foreground "blue")))
                                          ;; Update animation index
                                          (setq --emacs-spinner-index
                                                (mod
                                                 (1+ --emacs-spinner-index)
                                                 (length emacs-spinner-frames))))))
                                  (error
                                   (emacs-spinner-stop)))))))
      ;; Track active timers
      (push --emacs-spinner-timer --emacs-spinner-active-timers)
      --emacs-spinner-timer)))

(defun emacs-spinner-stop
    (&optional spinner-timer)
  "Stop the spinner animation.
If SPINNER-TIMER is provided, only stop that specific spinner.
Otherwise, stop the global spinner."
  (if spinner-timer
      (when
          (timerp spinner-timer)
        (cancel-timer spinner-timer)
        (setq --emacs-spinner-active-timers
              (delq spinner-timer --emacs-spinner-active-timers))
        (when
            (eq spinner-timer --emacs-spinner-timer)
          (setq --emacs-spinner-timer nil))
        (when
            (and --emacs-spinner-marker
                 (marker-buffer --emacs-spinner-marker))
          (with-current-buffer
              (marker-buffer --emacs-spinner-marker)
            (save-excursion
              (goto-char --emacs-spinner-marker)
              (condition-case nil
                  (progn
                    ;; Replace spinner with a space
                    (delete-char 1)
                    ;; (insert " ")
                    (setq --emacs-spinner-marker nil))
                (error nil))))))
    ;; No timer provided - stop global spinner
    (when --emacs-spinner-timer
      (cancel-timer --emacs-spinner-timer)
      (setq --emacs-spinner-active-timers
            (delq --emacs-spinner-timer --emacs-spinner-active-timers))
      (setq --emacs-spinner-timer nil)
      (when
          (and --emacs-spinner-marker
               (marker-buffer --emacs-spinner-marker))
        (with-current-buffer
            (marker-buffer --emacs-spinner-marker)
          (save-excursion
            (goto-char --emacs-spinner-marker)
            (condition-case nil
                (progn
                  ;; Replace spinner with a space
                  (delete-char 1)
                  ;; (insert " ")
                  (setq --emacs-spinner-marker nil))
              (error nil))))))))

(defun emacs-spinner-stop-all
    ()
  "Stop all running spinners."
  (interactive)
  (let
      ((timers-to-stop
        (copy-sequence --emacs-spinner-active-timers)))
    (dolist
        (timer timers-to-stop)
      (emacs-spinner-stop timer))
    (setq --emacs-spinner-timer nil)
    (setq --emacs-spinner-active-timers nil)
    (setq --emacs-spinner-marker nil)))

;;; emacs-spinner.el ends here
;; (emacs-spinner-stop)
;; (emacs-spinner-start)
;; (emacs-spinner-stop)
(message "emacs-spinner.el loaded."
         (file-name-nondirectory
          (or load-file-name buffer-file-name))))
(provide 'emacs-spinner)
(when
    (not load-file-name)
  (message "emacs-spinner.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))

(provide 'emacs-spinner)

(when
    (not load-file-name)
  (message "emacs-spinner.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))
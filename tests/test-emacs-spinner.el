;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-03-01 19:58:14>
;;; File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-spinner/tests/test-emacs-spinner.el

;;; test-emacs-spinner.el --- Tests for emacs-spinner.el -*- lexical-binding: t -*-

;; Author: ywatanabe
;; Keywords: tests

;;; Commentary:
;; Test suite for emacs-spinner.el

;;; Code:

(require 'ert)

(ert-deftest test-emacs-spinner-loadable
    ()
  "Test that the emacs-spinner package can be loaded."
  (require 'emacs-spinner)
  (should
   (featurep 'emacs-spinner)))

(ert-deftest test-emacs-spinner-frames-has-correct-default
    ()
  "Test that the default spinner frames are set correctly."
  (require 'emacs-spinner)
  (should
   (equal emacs-spinner-frames
          '("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"))))

(ert-deftest test-emacs-spinner-set-frames-updates-frames
    ()
  "Test that the spinner frames can be updated."
  (require 'emacs-spinner)
  (let
      ((test-frames
        '("A" "B" "C")))
    (unwind-protect
        (progn
          (emacs-spinner-set-frames test-frames)
          (should
           (equal emacs-spinner-frames test-frames)))
      ;; Cleanup - restore default frames
      (emacs-spinner-set-frames
       '("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")))))

(ert-deftest test-emacs-spinner-set-frames-resets-index
    ()
  "Test that setting frames resets the animation index."
  (require 'emacs-spinner)
  (let
      ((original-index --emacs-spinner-index)
       (test-frames
        '("A" "B" "C")))
    (unwind-protect
        (progn
          (setq --emacs-spinner-index 5)
          (emacs-spinner-set-frames test-frames)
          (should
           (= --emacs-spinner-index 0)))
      ;; Cleanup
      (setq --emacs-spinner-index original-index)
      (emacs-spinner-set-frames
       '("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")))))

(ert-deftest test-emacs-spinner-set-position-returns-buffer-position-pair
    ()
  "Test that set-position returns a cons with buffer and position."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-marker --emacs-spinner-marker))
      (unwind-protect
          (let
              ((result
                (emacs-spinner-set-position
                 (current-buffer)
                 5)))
            (should
             (consp result))
            (should
             (eq
              (car result)
              (current-buffer)))
            (should
             (=
              (cdr result)
              5)))
        (setq --emacs-spinner-marker original-marker)))))

(ert-deftest test-emacs-spinner-set-position-creates-marker
    ()
  "Test that set-position creates a marker at the specified position."
  (require 'emacs-spinner)
  (with-temp-buffer
    ;; Insert some text so position 5 is valid
    (insert "0123456789")
    (let
        ((original-marker --emacs-spinner-marker))
      (unwind-protect
          (progn
            (emacs-spinner-set-position
             (current-buffer)
             5)
            (should
             (markerp --emacs-spinner-marker))
            (should
             (eq
              (marker-buffer --emacs-spinner-marker)
              (current-buffer)))
            (should
             (=
              (marker-position --emacs-spinner-marker)
              5)))
        (setq --emacs-spinner-marker original-marker)))))

(ert-deftest test-emacs-spinner-start-returns-timer
    ()
  "Test that start returns a timer object."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-timer --emacs-spinner-timer)
         (original-marker --emacs-spinner-marker)
         (original-timers --emacs-spinner-active-timers))
      (unwind-protect
          (let
              ((timer
                (emacs-spinner-start
                 (current-buffer))))
            (should
             (timerp timer)))
        (emacs-spinner-stop-all)
        (setq --emacs-spinner-timer original-timer
              --emacs-spinner-marker original-marker
              --emacs-spinner-active-timers original-timers)))))

(ert-deftest test-emacs-spinner-start-adds-to-active-timers
    ()
  "Test that start adds the timer to active timers list."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-timer --emacs-spinner-timer)
         (original-marker --emacs-spinner-marker)
         (original-timers --emacs-spinner-active-timers))
      (unwind-protect
          (let
              ((timer
                (emacs-spinner-start
                 (current-buffer))))
            (should
             (member timer --emacs-spinner-active-timers)))
        (emacs-spinner-stop-all)
        (setq --emacs-spinner-timer original-timer
              --emacs-spinner-marker original-marker
              --emacs-spinner-active-timers original-timers)))))

(ert-deftest test-emacs-spinner-stop-cancels-timer
    ()
  "Test that stop cancels the timer."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-timer --emacs-spinner-timer)
         (original-marker --emacs-spinner-marker)
         (original-timers --emacs-spinner-active-timers))
      (unwind-protect
          (let
              ((timer
                (emacs-spinner-start
                 (current-buffer))))
            (emacs-spinner-stop timer)
            (should-not
             (member timer --emacs-spinner-active-timers)))
        (emacs-spinner-stop-all)
        (setq --emacs-spinner-timer original-timer
              --emacs-spinner-marker original-marker
              --emacs-spinner-active-timers original-timers)))))

(ert-deftest test-emacs-spinner-stop-all-clears-timers
    ()
  "Test that stop-all clears all timers."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-timer --emacs-spinner-timer)
         (original-marker --emacs-spinner-marker)
         (original-timers --emacs-spinner-active-timers))
      (unwind-protect
          (progn
            (emacs-spinner-start
             (current-buffer))
            (emacs-spinner-stop-all)
            (should-not --emacs-spinner-active-timers))
        (setq --emacs-spinner-timer original-timer
              --emacs-spinner-marker original-marker
              --emacs-spinner-active-timers original-timers)))))

(ert-deftest test-emacs-spinner-stop-all-clears-global-timer
    ()
  "Test that stop-all clears the global timer."
  (require 'emacs-spinner)
  (with-temp-buffer
    (let
        ((original-timer --emacs-spinner-timer)
         (original-marker --emacs-spinner-marker)
         (original-timers --emacs-spinner-active-timers))
      (unwind-protect
          (progn
            (emacs-spinner-start
             (current-buffer))
            (emacs-spinner-stop-all)
            (should-not --emacs-spinner-timer))
        (setq --emacs-spinner-timer original-timer
              --emacs-spinner-marker original-marker
              --emacs-spinner-active-timers original-timers)))))

(provide 'test-emacs-spinner)

(when
    (not load-file-name)
  (message "test-emacs-spinner.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))
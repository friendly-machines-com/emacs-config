;;; lc-media.el --- Deferred music, feeds, video and media browsing -*- lexical-binding: t; -*-
(require 'lc-core)
(require 'lc-ui)
(require 'use-package)
(defgroup lc-media nil "Music and media applications." :group 'lazy-config)
(defcustom lc-music-directory (lc-home-file "Music") "Library imported on first EMMS browsing."
  :type 'directory :group 'lc-media)
(defvar lc--music-imported nil)
(defun lc-emms-import-once (&rest _)
  (unless lc--music-imported
    (setq lc--music-imported t)
    (if (file-directory-p lc-music-directory)
        (condition-case err (emms-add-directory-tree lc-music-directory)
          (error (setq lc--music-imported nil) (signal (car err) (cdr err))))
      (display-warning 'lazy-config (format "Music directory missing: %s" lc-music-directory)))))
(use-package emms :ensure nil :commands (emms emms-smart-browse emms-play-file)
  :config
  (require 'emms-setup) (emms-all)
  (require 'emms-player-mpv) (require 'emms-info-libtag) (require 'org-emms)
  (dolist (command '(emms emms-smart-browse emms-browse-by-album emms-browse-by-year
                          emms-browse-by-genre emms-browse-by-artist emms-browse-by-composer
                          emms-browse-by-performer))
    (advice-add command :before #'lc-emms-import-once))
  (add-hook 'emms-browser-mode-hook #'variable-pitch-mode)
  (add-hook 'emms-playlist-mode-hook #'variable-pitch-mode)
  (easy-menu-define lc-emms-browser-menu emms-browser-mode-map "Music browser actions"
    '("Music" ["Browse by album" emms-browse-by-album t] ["Browse by year" emms-browse-by-year t]
      ["Browse by genre" emms-browse-by-genre t] ["Browse by artist" emms-browse-by-artist t]
      ["Browse by composer" emms-browse-by-composer t] ["Browse by performer" emms-browse-by-performer t]
      ["Add tracks and play" emms-browser-add-tracks-and-play t]
      ["Collapse all" emms-browser-collapse-all t] ["Expand all" emms-browser-expand-all t]))
  (easy-menu-define lc-emms-playlist-menu emms-playlist-mode-map "Music playback"
    '("Music" ["Play" emms-playlist-mode-play-smart t] ["Seek backward" emms-seek-backward t]
      ["Seek forward" emms-seek-forward t] ["Pause" emms-pause t]
      ["Previous track" emms-previous t] ["Next track" emms-next t] ["Stop" emms-stop t]
      ["Edit tags" emms-tag-editor-edit t] ["External tag editor" emms-tag-editor-pipe t])))
(defun lc-video-url-p (url)
  (string-match-p "\\`https?://\\(?:www\\.\\)?\\(?:youtube\\.com/\\|youtu\\.be/\\)\\|\\.\\(?:mp4\\|wmv\\)\\(?:[?#].*\\)?\\'" url))
(defun lc-browse-video (url &optional _new-window)
  (lc-require 'mpv) (mpv-start url "--fs"))
(with-eval-after-load 'browse-url
  (add-to-list 'browse-url-handlers '(lc-video-url-p . lc-browse-video)))
(use-package mpv :ensure nil :commands (mpv-start mpv-play-url))
(use-package mediainfo-mode :ensure nil
  :mode ("\\.\\(?:jpg\\|jpeg\\|png\\|gif\\|3gp\\|aiff\\|avi\\|flac\\|m4a\\|mkv\\|mov\\|mp3\\|mp4\\|mpg\\|ogg\\|opus\\|vob\\|wav\\|webm\\|wmv\\)\\'" . mediainfo-mode)
  :config
  (setq mediainfo-mode-open-method #'emms-play-file)
  (easy-menu-define lc-mediainfo-menu mediainfo-mode-map "Media information"
    '("Media" ["Play" mediainfo-mode-open t])))
(defun lc-elfeed-print-entry (entry)
  (let* ((title (or (elfeed-meta entry :title) (elfeed-entry-title entry) ""))
         (feed (elfeed-entry-feed entry))
         (feed-title (and feed (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
         (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
         (width (elfeed-clamp elfeed-search-title-min-width
                              (- (window-width) 10 elfeed-search-trailing-width) elfeed-search-title-max-width)))
    (insert (propertize (elfeed-search-format-date (elfeed-entry-date entry)) 'face 'elfeed-search-date-face) " ")
    (insert (propertize (elfeed-format-column title width :left)
                        'face (elfeed-search--faces (elfeed-entry-tags entry)) 'help-echo title) "\t")
    (when feed-title (insert (propertize feed-title 'face 'elfeed-search-feed-face) " "))
    (when tags (insert "(" (propertize (mapconcat #'identity tags ",") 'face 'elfeed-search-tag-face) ")"))))
(use-package elfeed :ensure nil :commands elfeed
  :config (setq elfeed-search-print-entry-function #'lc-elfeed-print-entry))
(use-package elfeed-tube :ensure nil :after elfeed :demand t
  :config (elfeed-tube-setup)
  :bind (:map elfeed-show-mode-map ("F" . elfeed-tube-fetch) ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map ("F" . elfeed-tube-fetch) ([remap save-buffer] . elfeed-tube-save)))
(use-package elfeed-tube-mpv :ensure nil :after elfeed-tube :demand t
  :bind (:map elfeed-show-mode-map ("C-c C-f" . elfeed-tube-mpv-follow-mode) ("C-c C-w" . elfeed-tube-mpv-where)))
(defun lc-elfeed-follow (path _arg) (lc-require 'elfeed-link) (elfeed-link-open path))
(defun lc-elfeed-store ()
  (when (derived-mode-p 'elfeed-show-mode) (lc-require 'elfeed-link) (elfeed-link-store-link)))
(defun lc-elfeed-export (link desc format _protocol)
  "Export the original article URL, with a defined fallback for missing entries."
  (lc-require 'elfeed)
  (let* ((id (and (string-match "\\([^#]+\\)#\\(.+\\)" link)
                  (cons (match-string 1 link) (match-string 2 link))))
         (entry (and id (elfeed-db-get-entry id)))
         (url (or (and entry (elfeed-entry-link entry)) link))
         (label (or desc (and entry (elfeed-entry-title entry)) url)))
    (pcase format
      ('html (require 'xml) (format "<a href=\"%s\">%s</a>" (xml-escape-string url) label))
      ('md (format "[%s](%s)" label url)) ('latex (format "\\href{%s}{%s}" url label))
      ('texinfo (format "@uref{%s,%s}" url label)) (_ (format "%s (%s)" label url)))))
(with-eval-after-load 'org
  (org-link-set-parameters "elfeed" :follow #'lc-elfeed-follow :store #'lc-elfeed-store :export #'lc-elfeed-export))
(lc-register-actions '((add-play "Add and play" emms-browser-add-tracks-and-play "mpc/add")
                  (play "Play" emms-playlist-mode-play-smart "mpc/play")
                  (rewind "Seek back" emms-seek-backward "mpc/rewind")
                  (ffwd "Seek forward" emms-seek-forward "mpc/ffwd")
                  (pause "Pause" emms-pause "mpc/pause") (music-prev "Previous" emms-previous "mpc/prev")
                  (music-next "Next" emms-next "mpc/next") (stop "Stop" emms-stop "mpc/stop")
                  (media-play "Play" mediainfo-mode-open "mpc/play")))
(provide 'lc-media)

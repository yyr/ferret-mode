;;; ferret.el --- Ferret mode for GNU Emacs

;; Copyright (c) 1999 by Mark A. Verschell <verschell@neptune.gsfc.nasa.gov>

;; Author: Mark A. Verschell <verschell@neptune.gsfc.nasa.gov>
;; Maintainer: Mark A. Verschell <verschell@neptune.gsfc.nasa.gov>
;; Version 0.90 (2016-01-19)
;; Keywords: languages

;; Ferret.el is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License, version 2, published by the
;; Free Software Foundation.

;; You should have received a copy of the GNU General Public License along
;; with GNU Emacs; see the file COPYING.  If not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA,
;; or refer to the WWW document "http://www.gnu.org/copyleft/gpl.html";.

;; Ferret.el is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; Information about "Ferret", a graphical analysis tool for gridded data, can
;; be found at "http://ferret.pmel.noaa.gov/Ferret/";

;; Documentation
;; -------------
;; IMPORTANT NOTE: This only works with X-windows emacs, and only for
;; semi-recent versions of emacs (18.xx and above)
;;
;; This is Ferret mode for GNU emacs, a major mode designed to facilitate the
;; writing of journal files for "Ferret", a graphical analysis tool for
;; gridded data.
;;
;; Ferret mode for emacs is limited at this time to font-lock coverage
;; This means that the following is supported:
;;   Commands, subcommands, and aliases with most abbreviations
;;   Command and subcommand qualifiers with most abbreviations
;;   Comments starting with ! anywhere on line are supported
;;   Subroutines (go calls) are supported
;;   Shell command called by spawn is supported
;;   Strings are supported between ""
;;   Functions, operators, and transformations are supported
;;   Font-lock mode is case-insensitive
;;
;; Version updates
;;   0.02.2 - Corrected small error to make vector a recognized command
;;   0.02.3 - Allowed function and shell commands with embedded "_"
;;            Added noaxis to list of qualifiers
;;            Allowed abbreviation can for cancel
;;   0.03.0 - Added PPLUS commands
;;            Added PPLUS qualifiers
;;            Added symbol name highlighting
;;            Added version update history
;;            Allowed function and shell commands with embedded "."
;;            Fixed problem with 0.02.03 that broke comments
;;            Files highlighted for USE and SET DATA (except with qualifiers)
;;            Removed ca as abbreviation for cancel


;;; Code:

(defconst ferret-mode-version "version 0.90")

(defgroup ferret nil
  "Ferret mode for Emacs"
  :group 'languages)

;; font-lock-comment-face        - COMMENTS
;; font-lock-function-name-face  - FUNCTION NAMES, SHELL COMMANDS
;; font-lock-keyword-face        - COMMANDS, SUBCOMMANDS, OPERATORS, FUNCTIONS,
;;                                 TRANSFORMATIONS
;; font-lock-reference-face
;; font-lock-string-face         - STRINGS
;; font-lock-type-face           - QUALIFIERS
;; font-lock-variable-name-face

(let ((comment-chars "!")
      (ferret-keywords
                                        ;      ("alias" "animate" "axis" "cancel" "commands" "contour" "data_set"
                                        ;       "dataset" "define" "elif" "else" "endif" "exit" "expression" "file"
                                        ;       "fill" "frame" "function" "grid" "help" "if" "label" "let" "list"
                                        ;       "load" "memory" "message" "mode" "movie" "palette" "plot" "pplus"
                                        ;       "queries" "query" "quit" "region" "repeat" "save" "say" "set" "shade"
                                        ;       "show" "statistics" "symbol" "then" "transform" "unalias" "use" "user"
                                        ;       "variable" "vector" "viewport" "window" "wire"))
       (concat "a\\(lias?\\|nima?t?e?\\|xis\\)\\|"
               "c\\(anc?e?l?\\|o\\(mma?n?d?s?\\|nto?u?r?\\)\\)\\|"
               "d\\(ata[_]*?s?e?t?\\|efi?n?e?\\)\\|"
               "e\\(l\\(if\\|se\\)\\|ndif?\\|x\\(it\\|pre?s?s?i?o?n?\\)\\)\\|"
               "f\\(i\\(le\\|ll\\)\\|rame?\\|unct?i?o?n?\\)\\|"
               "grid\\|help\\|if\\|"
               "l\\(abe?l?\\|et\\|ist\\|oad\\)\\|"
               "m\\(e\\(mo?r?y?\\|ssa?g?e?\\)\\|o\\(de\\|vi?e?\\)\\)\\|"
               "p\\(ale?t?t?e?\\|lot\\|plu?s?\\)\\|"
               "qu\\(e\\(ri?e?s?\\|ry?\\)\\|it\\)\\|"
               "re\\(gio?n?\\|pe?a?t?\\)\\|"
               "s\\(a\\(ve\\|y\\)\\|et\\|h\\(ade?\\|ow\\)\\|tati?s?t?i?c?s?"
               "\\|ymbo?l?\\)\\|"
               "t\\(hen\\|rans?f?o?r?m?\\)\\|"
               "u\\(nali?a?s?\\|ser?\\)\\|"
               "v\\(ari?a?b?l?e?\\|ect?o?r?\\|iewp?o?r?t?\\)\\|"
               "wi\\(ndo?w?\\|re\\)"))
      (ferret-qualifiers
                                        ;       "all" "append" "aspect" "bad" "brief" "clear" "clip" "clobber"
                                        ;       "columns" "command" "compress" "continue" "d" "data_set" "dataset"
                                        ;       "default" "depth" "di" "diag" "dj" "dk" "dl" "dt" "dx" "dy" "dynamic"
                                        ;       "dz" "external" "ez" "file" "fill" "format" "frame" "free" "from_data"
                                        ;       "fromdata" "full" "grid" "heading" "help" "i" "ignore" "ilimits" "j"
                                        ;       "jlimits" "k" "key" "klimits" "l" "laser" "last" "length" "levels"
                                        ;       "like" "line" "llimits" "location" "modulo" "name" "new" "noaxes"
                                        ;       "noaxis" "noerror" "nohead" "nokey" "nolabel" "npoints" "nouser" "opt1"
                                        ;       "opt2" "order" "origin" "overlay" "palette" "pen" "permanent"
                                        ;       "precision" "quiet" "reset" "restore" "rigid" "save" "set_up" "single"
                                        ;       "size" "skip" "start" "symbol" "t" "t0" "temporary" "text" "title"
                                        ;       "tlimits" "tranpose" "units" "user" "variable" "viewpoint" "vs" "x"
                                        ;       "xlimits" "xskip" "y" "ylimits" "yskip" "z" "zlimits" "zscale"
       (concat "a\\(ll\\|ppe?n?d?\\|spe?c?t?\\)\\|"
               "b\\(ad\\|rief?\\)\\|"
               "c\\(l\\(ear?\\|ip\\|obb?e?r?\\)\\|o\\(lu?m?n?s?\\|m\\(ma?n?d?"
               "\\|mpr?e?s?s?\\)\\|nti?n?u?e?\\)\\)\\|"
               "d\\(\\|ata[_]*s?e?t?\\|e\\(fa?u?l?t?\\|pt?h?\\)\\|i\\(\\|ag\\)"
               "\\|j\\|k\\|l\\|t\\|x\\|y\\(\\|na?m?i?c?\\)\\|z\\)\\|"
               "e\\(xte?r?n?a?l?\\|z\\)\\|"
               "f\\(il[el]\\|orm?a?t?\\|r\\(ame?\\|ee\\|om[_]*d?a?t?a?\\)"
               "\\|ull\\)\\|"
               "grid\\|"
               "he\\(adi?n?g?\\|lp\\)\\|"
               "i\\(\\|gno?r?e?\\|li?m?i?t?s?\\)\\|"
               "j\\(\\|li?m?i?t?s?\\)\\|"
               "k\\(\\|ey\\|li?m?i?t?s?\\)\\|"
               "l\\(\\|as\\(er?\\|t\\)\\|e\\(ngt?h?\\|ve?l?s?\\)\\|i\\(ke\\|ne"
               "\\)\\|li?m?i?t?s?\\|oca?t?i?o?n?\\)\\|"
               "modu?l?o?\\|"
               "n\\(ame\\|ew\\|o\\(ax\\(e?\\i?\\)s?\\|err?o?r?\\|hea?d?\\|key?"
               "\\|lab?e?l?\\|use?r?\\)\\|poin?t?s?\\)\\|"
               "o\\(p\\(t1\\|t2\\)\\|r\\(der?\\|igi?n?\\)\\|verl?a?y?\\)\\|"
               "p\\(ale?t?t?e?\\|e\\(n\\|rma?n?e?n?t?\\)\\|reci?s?i?o?n?\\)\\|"
               "quiet?\\|"
               "r\\(e\\(s\\(et?\\|to?r?e?\\)\\)\\|igi?d?\\)\\|"
               "s\\(ave?\\|et_?u?p?\\|i\\(ngl?e?\\|ze\\)\\|kip\\|tart?"
               "\\|ymb?o?l?\\)\\|"
               "t\\(\\|0\\|e\\(mpo?r?a?r?y?\\|xt\\)\\|itl?e?\\|li?m?i?t?s?"
               "\\|ranp?o?s?e?\\)\\|"
               "u\\(nits?\\|ser?\\)\\|"
               "v\\(ari?a?b?l?e?\\|iewp?o?i?n?t?\\|s\\)\\|"
               "x\\(\\|li?m?i?t?s?\\|ski?p?\\)\\|"
               "y\\(\\|li?m?i?t?s?\\|ski?p?\\)\\|"
               "z\\(\\|li?m?i?t?s?\\|sca?l?e?\\)"))
      (ferret-operators
                                        ;       "and" "eq" "ge" "gt" "le" "lt" "ne" "or"
       (concat "and\\|eq\\|g[et]\\|l[et]\\|ne\\|or"))
      (ferret-functions
                                        ;       "abs" "acos" "asin" "atan" "atan2" "cos" "days1900" "exp" "ignore0"
                                        ;       "int" "ln" "log" "max" "min" "missing" "mod" "randn" "randu" "reshape"
                                        ;       "rho_un" "sin" "tan" "theta_fo" "times2" "unravel" "zaxreplace"
       (concat "a\\(bs\\|cos\\|sin\\|tan2?\\)\\|cos\\|days1900\\|exp\\|"
               "i\\(gnore0\\|nt\\)\\|l\\(n\\|og\\)\\|m\\(ax\\|i\\(n\\|ssing\\)"
               "\\|od\\)\\|r\\(and[nu]\\|eshape\\|ho_un\\)\\|sin\\|t\\(an\\|"
               "heta_fo\\|imes2\\)\\|unravel\\|zaxreplace"))
      (ferret-transformations
                                        ;       "asn" "ave" "ave" "cda" "cdb" "cia" "cib" "ddb" "ddc" "ddf" "din"
                                        ;       "fav" "fln" "fnr" "iin" "itp" "lin" "loc" "max" "max" "min" "min"
                                        ;       "mod" "modmax" "modmin" "modngd" "modsum" "modvar" "nbd" "ngd" "ngd"
                                        ;       "rsum" "sbn" "sbx" "shf" "shn" "spz" "sum" "sum" "swl" "var" "var"
                                        ;       "weq" "xact"
       (concat "a\\(sn\\|ve\\)\\|c\\(d[ab]\\|i[ab]\\)\\|d\\(d[bcf]\\|in\\)\\|"
               "f\\(av\\|l[nr]\\)i\\(in\\|tp\\)\\|l\\(in\\|oc\\)\\|m\\(ax\\|in"
               "\\|od\\(\\|m\\(ax\\|in\\)\\|ngd\\|sum\\|var\\)\\)\\|n[bg]d"
               "\\|rsum\\|s\\(b[nx]\\|h[fn]\\|pz\\|um\\|wl\\)\\|var\\|weq"
               "\\|xact"))
      (pplus-keywords
                                        ;      ("aline" "axatic" "axlabp" "axlen" "axlint" "axlsze" "axnmtc" "axnsig"
                                        ;      "axset" "axtype" "box" "clsplt" "color" "conpre" "conpst" "conset"
                                        ;      "contour" "cross" "datpt" "dfltfnt" "fill" "hlabs" "labs" "labset" "lev"
                                        ;      "line" "list" "llabs" "markh" "origin" "pen" "plot" "plotuv" "plotv"
                                        ;      "pltnme" "rlabs" "shade" "shakey" "shaset" "taxis" "tics" "time" "title"
                                        ;      "txlabp" "txlint" "txlsze" "txnmtc" "txtype" "veckey" "vecset" "vector"
                                        ;      "velvct" "view" "vpoint" "xaxis" "xfor" "xlab" "yaxis" "yfor" "ylab"))
       (concat "a\\(line\\|x\\(atic\\|l\\(abp\\|en\\|int\\|sze\\)\\|n\\(mtc\\|"
               "sig\\)\\|set\\|type\\)\\)\\|"
               "box\\|"
               "c\\(lsplt\\|o\\(lor\\|n\\(p\\(re\\|st\\)\\|set\\)\\)\\|"
               "ross\\)\\|"
               "d\\(atpt\\|fltfnt\\)\\|"
               "hlabs\\|"
               "l\\(abs\\(\\|et\\)\\|ev\\|ine\\|labs\\)\\|"
               "markh\\|"
               "origin\\|"
               "p\\(en\\|l\\(ot\\(\\|uv\\|v\\)\\|tnme\\)\\)\\|"
               "rlabs\\|"
               "sha\\(key\\|set\\)\\|"
               "t\\(axis\\|i\\(cs\\|me\\|tle\\)\\|x\\(l\\(abp\\|int\\|sze\\)"
               "\\|nmtc\\|type\\)\\)\\|"
               "v\\(e\\(c\\(key\\|set\\)\\|lvct\\)\\|iew\\|point\\)\\|"
               "x\\(axis\\|for\\|lab\\)\\|"
               "y\\(axis\\|for\\|lab\\)"))
      (pplus-qualifiers
                                        ;       "nooverlay" "nowait" "noyaxis" "wait" "yaxis"
       (concat "no\\(overlay\\|wait\\|yaxis\\)\\|wait\\|yaxis"))
      )

  (setq ferret-font-lock-keywords
        (list
         '("\"[^'\n]*'?" . font-lock-comment-face)
         (cons (concat "$[A-Za-z0-9$]*") 'font-lock-variable-name-face)
         (list (concat
                "\\<\\(data[_]*?s?e?t?\\|go\\|spawn?\\|use\\)\\>[ \t]*\\(\\sw+\\)?")
               '(1 font-lock-keyword-face)
               '(2 font-lock-function-name-face nil t))
         (cons (concat "\\/\\(" ferret-qualifiers "\\)\\>") 'font-lock-type-face)
         (cons (concat "\\/\\(" pplus-qualifiers "\\)\\>") 'font-lock-type-face)
         (concat "\\<\\(" ferret-keywords "\\)\\>")
         (concat "\\<\\(" pplus-keywords "\\)\\>")
         (concat "\\<\\(" ferret-operators "\\)\\>")
         (concat "\\<\\(" ferret-functions "\\)\\>")
         (concat "\\@\\(" ferret-transformations "\\)\\>")
         ))
  "Default expressions to highlight in Ferret mode.")

;;;###autoload
(define-derived-mode ferret-mode text-mode "Ferret"
  "Major mode for editing ferret .jnl files.
Special commands:
\\{ferret-mode-map}"
  (set (make-local-variable 'comment-start) "! ")
  (set-syntax-table (copy-syntax-table))
  (modify-syntax-entry ?! "<")
  (modify-syntax-entry ?\n ">")
  (modify-syntax-entry ?_ "w")
  (modify-syntax-entry ?. "w")
  (set (make-local-variable 'font-lock-defaults)
       '(ferret-font-lock-keywords nil t)))

;;;###autoload
(add-to-list 'auto-mode-alist (cons (purecopy "\\.jnl\\'") 'ferret-mode))

(provide 'ferret)

;;; ferret.el ends here

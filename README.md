# init-panel

A minor mode that shows an Emacs configuration written as a comment outline
as a panel: sections folded and drawn with rules and icons, `;>` notes aligned
in a column and decorated with keys, badges and links, a kind icon per form in
the left margin, a marker on the current heading, a breadcrumb in the header
line, and a keyword summary on folded `use-package` forms.

It sits on top of `outline-minor-mode` (Emacs 29.1 or later), has no
dependencies, and works in a terminal frame. A glyph the display cannot
show falls back to plain text.

```
▸  ────────────────────────────────────────────────────── Core
▸  ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ Navigation
   󰛢 (add-hook 'after-init-hook #'column-number-mode)     → show column number in modeline
    (setq-default truncate-lines t)                       → [fix]: long lines never wrap here — see `truncate-partial-width-windows'
    (use-package winner  hook bind config ⬎               → undo/redo window layout changes
   ───────────────────────────────────────────────────── Visuals
   ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ Themes
 header line:  Core › Navigation
```

## The file convention

The file convention is two note markers and one heading syntax:

```elisp
;;; Section                            ;; level 1 (or ";;; ------- Section", both render the same)
;;;; Subsection                        ;; level 2
(setq foo t) ;> why this line exists   ;; a note — the WHY, one line
             ;. continuation           ;; a note continuation (or a sub-item inside a block)
(setq bar t) ;> [fix]: C-c w reopens `my-workspaces' after a theme change
```

- A note starts with `;>` (or `#>` in a `#`-comment language: the markers are
  built from `comment-start`). One space before it is enough; the mode draws
  the column.
- `[tag]:` at the start of a note becomes a badge. The default vocabulary:
  `fix` `bug` (warning) · `hack` `deprecated` (error) · `perf` (success) ·
  `todo` `wip` · `emacs30` (version). Anything else gets a neutral badge.
- Keys like `C-c w`, `M-x foo`, `<f5>`, `TAB` are shown in the key face.
- `` `symbol' `` links to `describe-symbol`; a bare `my-func` or `my/var`
  links too when it names a bound function, variable or face.

## Install

```elisp
;; straight
(use-package init-panel
  :straight (:host github :repo "mahatmus-tech/init-panel")
  :hook (hack-local-variables . init-panel-maybe-enable)   ; enable where a file asks for it
  ;; only when loading from a plain directory (no autoloads): declare the
  ;; file-local variable safe before any file is visited
  ;; :init (put 'init-panel 'safe-local-variable #'booleanp)
  :bind (:map init-panel-mode-map
              ("C-c C-t" . init-panel-show-headings)     ; every heading and top-level form
              ("C-c C-s" . init-panel-fold-subsections)  ; sections + subsections
              ("C-c C-y" . init-panel-fold)              ; sections only (the open-file state)
              ("C-c C-o" . init-panel-focus)))           ; edit the block at point in a popup
```

Then opt each file in with a file-local variable on its first line — the
panel never turns itself on anywhere else, so an ordinary `.el` stays
ordinary:

```elisp
;;; init.el --- my config -*- lexical-binding: t; init-panel: t -*-
```

(or a local-variables block at the end; `init-panel` is declared safe for
booleans, so Emacs won't ask). Works in any major mode: `# -*- init-panel: t -*-`
in a `.zshrc` does the same.

The mode map is empty on purpose; bind what you like. The bindings above use `C-c C-<letter>`, which Emacs reserves for major modes, so they can shadow a mode's own commands; pick other keys if one collides. `TAB` / `S-TAB` on a
heading cycle it / the whole buffer — that is Emacs' own
`outline-minor-mode-cycle`.

## What it does, and the switch for each

| Feature | Option | Fallback |
|---|---|---|
| Fold to sections on open, `TAB`/`S-TAB` cycling, heading faces | always (native outline) | — |
| Notes aligned at a drawn column | `init-panel-style` `'column`, `init-panel-column` 70 | `'margin` puts them in the right margin |
| Column follows the widest visible code line | `init-panel-column-auto` nil | — |
| Section rules as `─` / `╌` | `init-panel-rule-chars` | typed dashes |
| Icon per section from its name | `init-panel-section-icons` | `◆` / `◇`, then `;;;` |
| Icon per form kind in the left margin (4 cells) | `init-panel-kind-margin`, `init-panel-kind-icons`, `init-panel-margin-cells` | none |
| "You are here" marker on the current section/subsection headings (or a bar along the section) | `init-panel-section-guide` `'marker` / `'bar` / nil, `init-panel-marker-char` | none |
| Plain `;;` / `;` comments: quiet glyph, plus the note decorations below | `init-panel-prose-comments` | as typed |
| Keys in the key face | `init-panel-highlight-keys` | plain |
| `[tag]` badges | `init-panel-tag-faces` | neutral badge |
| Symbol links (`RET` / mouse-1 → describe) | `init-panel-link-symbols` | plain |
| First argument of every form (the variable, hook, key, package) in its own face | `init-panel-highlight-targets` | plain |
| Right-margin width in `margin` style | `init-panel-margin-width`, `init-panel-margin-min`, `init-panel-margin-max`, `init-panel-min-code-width` | collapses to `column` when there is no room |
| "Packages" group in imenu | `init-panel-package-index` | — |
| Folded `use-package` shows its keywords | `init-panel-fold-summary` | — |
| `Section › Subsection` header line for the section point is in | `init-panel-header-line` `'point` / `'window-start` / nil | — |
| `which-function-mode` shows the section path | always | — |
| Flymake end-of-line text hidden while reading | `init-panel-quiet-diagnostics` | — |
| Focus: edit the block at point in an indirect buffer over the panel | `init-panel-focus`, `init-panel-focus-frame`, `init-panel-focus-max-height` | window below instead of a child frame |
| Note of the form at point echoed via eldoc | `init-panel-eldoc` nil / t | — |
| Line at point shown as typed | `init-panel-raw-at-point` nil | — |

Icons default to [Nerd Font](https://www.nerdfonts.com/) codepoints. Each glyph is checked
with `char-displayable-p` before it is drawn; one the display cannot render is
skipped and the typed text shows instead. Set the icon options to plain
characters if you do not use a Nerd Font.

## Commands

- `init-panel-mode` — the minor mode.
- `init-panel-fold` / `init-panel-fold-subsections` / `init-panel-show-headings` — the three fold states.
- `init-panel-toggle-style` — column ↔ right margin, per buffer.
- `init-panel-normalize-buffer` / `init-panel-normalize-region` — strip typed layout (heading dashes, note padding) from a file that was aligned by hand; the panel draws it anyway.
- `init-panel-describe-at-point` — what `RET` on a link runs.
- `init-panel-focus` / `init-panel-focus-close` / `init-panel-focus-abort` — open the section or form at point in an indirect buffer (child frame on GUI, window in a terminal); `C-c C-c` returns, `C-c C-k` undoes what you did there and returns. Edits are the file's own text: nothing is copied or synced back, undo is shared.

## How it is built

Everything is font-lock keywords with `display` properties (rules, glyphs, the
aligned column — measured in the text's own font width, so `C-x C-+` zoom keeps
notes aligned), a handful of overlays in the left margin managed by
`jit-lock`, and the built-in hooks (`window-size-change-functions`,
`outline-view-change-hook`, `post-command-hook` for the guide). jit-lock only
fontifies what is on screen. For scale: fontifying a whole generated
1000-line init with `font-lock-ensure`, byte-compiled, takes roughly 70-110 ms
in batch Emacs 31 (including the stock Emacs Lisp highlighting).

## Options

All options are in the `init-panel` customize group.

| Option | Default | Effect |
|---|---|---|
| `init-panel-style` | `column` | Where notes are drawn: `column` or `margin` (right margin). |
| `init-panel-column` | 70 | Column notes align to in `column` style. |
| `init-panel-column-auto` | nil | Push the column right past the widest visible code line. |
| `init-panel-margin-width` | `auto` | Right margin width in `margin` style. |
| `init-panel-margin-min` | 24 | Below this width the `auto` margin collapses to zero. |
| `init-panel-margin-max` | 60 | Widest margin `auto` will use. |
| `init-panel-min-code-width` | 60 | Columns always kept for code when sizing the margin. |
| `init-panel-eldoc` | nil | Echo the note of the form at point through eldoc. |
| `init-panel-raw-at-point` | nil | Show the line at point exactly as typed. |
| `init-panel-heading-column` | 70 | Visual column where a heading name starts when its rule is drawn. |
| `init-panel-rule-chars` | `─` / `╌` | Rule character per heading level. |
| `init-panel-glyph-alist` | `◆` `◇` … | Marker to glyph shown in its place. |
| `init-panel-prose-comments` | t | Decorate plain `;;` / `;` comments too. |
| `init-panel-section-icons` | name regexps | Heading name to icon. |
| `init-panel-kind-margin` | t | Show a form-kind icon in the left margin. |
| `init-panel-kind-icons` | head-symbol regexps | Head symbol of a form to icon. |
| `init-panel-margin-cells` | 4 | Left margin width: marker, a space, the icon. |
| `init-panel-section-guide` | `marker` | Current-section indicator: `marker`, `bar` or nil. |
| `init-panel-marker-char` | `▸` | Character used by the `marker` guide. |
| `init-panel-guide-char` | `│` | Character used by the `bar` guide. |
| `init-panel-highlight-keys` | t | Key face for key descriptions in notes. |
| `init-panel-tag-faces` | fix, bug, hack, … | `[tag]` word to badge face. |
| `init-panel-link-symbols` | t | Symbol names in notes become links to their docs. |
| `init-panel-package-index` | t | List `use-package` names under "Packages" in imenu. |
| `init-panel-highlight-targets` | t | Give the first argument of each form its own face. |
| `init-panel-fold-summary` | t | Show keywords of a folded `use-package` form. |
| `init-panel-header-line` | `point` | Breadcrumb: `point`, `window-start` or nil. |
| `init-panel-quiet-diagnostics` | t | Hide end-of-line checker text while the mode is on. |
| `init-panel-ellipsis` | ` ⬎` | Text at the end of a folded heading. |
| `init-panel-use-buttons` | nil | Value for `outline-minor-mode-use-buttons` while the mode is on. |
| `init-panel-focus-frame` | t | Open focus in a child frame on graphical displays. |
| `init-panel-focus-max-height` | 40 | Most lines a focus frame or window takes. |

## Limitations

- The panel turns on only where a file asks for it (`init-panel: t`); it never enables itself in an ordinary buffer.

## Status

Version 0.2.0, extracted from the author's own config. Tests: `make test`
(ERT). `make compile` and `make checkdoc` run clean; `make lint` needs
`package-lint` (see the Makefile).

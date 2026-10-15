# Changelog

## 0.2.0 — unreleased

First standalone version, extracted from a personal Emacs config. Not
tagged yet.

- Folding through `outline-minor-mode`: opens folded to sections,
  `TAB` / `S-TAB` cycling, heading faces
- Notes (`;>` / `;.`) drawn at a column with a `display` property, so they
  stay aligned under text zoom; optional right-margin style
- Section rules in box-drawing characters and an icon per section, chosen
  from its name
- Left margin: an icon for each top-level form's kind and a marker on the
  current section and subsection headings
- Note decorations: keys, `[tag]` badges, symbol links (`RET` runs
  `describe-symbol`); plain `;;` / `;` comments get quiet glyphs and the
  same decorations
- First argument of each top-level form (variable, hook, key, package) in
  its own face; "Packages" group in imenu
- Folded `use-package` forms show a summary of their keywords;
  `Section › Subsection` breadcrumb in the header line
- Flymake end-of-line diagnostics hidden while the mode is on
- Per-file opt-in: the `init-panel: t` file-local variable plus
  `init-panel-maybe-enable` on `hack-local-variables-hook`; the mode never
  turns itself on elsewhere
- Three fold commands; the mode keymap is empty by design
- Key detection matches whole words only (`has-agenda-view`, `SECRET` and
  `<style>` are not keys; `M-x cmd`, `C-x o o o` and `M-S-<up>` are)
- Separate faces for `;>`, `;.` and prose comment markers
- `init-panel-normalize-buffer` strips hand-typed alignment; the imenu
  index sees through folding
- `init-panel-focus`: edit one block in an indirect buffer, in a child
  frame or a window below; `C-c C-c` closes, `C-c C-k` discards the edits
- Right-margin notes no longer start with a stray `>` when the comment
  starter is longer than one character (`//`)
- ERT test suite and a Makefile (`test`, `compile`, `checkdoc`, `lint`)

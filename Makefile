EMACS ?= emacs
PKG   := init-panel

.PHONY: test compile checkdoc lint clean

test:
	$(EMACS) -Q --batch -L . -l ert -l $(PKG)-tests.el -f ert-run-tests-batch-and-exit

compile:
	$(EMACS) -Q --batch -L . --eval '(setq byte-compile-error-on-warn t)' -f batch-byte-compile $(PKG).el
	rm -f $(PKG).elc

checkdoc:
	@out=$$($(EMACS) -Q --batch --eval '(checkdoc-file "$(PKG).el")' 2>&1); \
	  echo "$$out"; \
	  if echo "$$out" | grep -q '^$(PKG).el:[0-9]'; then exit 1; fi

# Needs package-lint on the load path (M-x package-install RET package-lint,
# or LINT_DIR=/path/to/package-lint).
LINT_DIR ?=

lint:
	$(EMACS) -Q --batch -L . $(if $(LINT_DIR),-L $(LINT_DIR)) \
	  --eval '(unless (require (quote package-lint) nil t) (error "package-lint not found; set LINT_DIR"))' \
	  -f package-lint-batch-and-exit $(PKG).el

clean:
	rm -f *.elc

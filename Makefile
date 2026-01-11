.PHONY: install doctor uninstall fmt lint

install:
	./install.sh

doctor:
	./doctor.sh

uninstall:
	./uninstall.sh

fmt:
	shfmt -w scripts/**/*.sh config/**/*.sh || true

lint:
	shellcheck scripts/**/*.sh || true

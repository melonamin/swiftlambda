prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/swiftlambda" "$(bindir)"

uninstall:
	rm "$(bindir)/swiftlambda"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
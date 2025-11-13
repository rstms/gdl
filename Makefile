# go makefile

program != basename $$(pwd)

go_version = go1.24.5

latest_release != gh release list --json tagName --jq '.[0].tagName' | tr -d v
version != cat VERSION

rstms_modules = $(shell awk <go.mod '/^module/{next} /rstms/{print $$1}')

gitclean = $(if $(shell git status --porcelain),$(error git status is dirty),$(info git status is clean))

$(program): .fmt
	go build -ldflags "-linkmode external -extldflags '-static'" .

build: $(program)

go.mod:
	$(go_version) mod init

go.sum: go.mod
	go mod tidy
	@touch $@

.fmt: $(wildcard *.go) go.sum
	fix go fmt .
	@touch $@

fmt: .fmt
	fix go fmt . ./...

test: fmt
	go test -v -failfast . ./...

debug: fmt
	go test -v -failfast -count=1 -run $(test) . ./...

release: $(package_tarball)
	$(gitclean)
	@$(if $(update),gh release delete -y v$(version),)
	gh release create v$(version) --notes "v$(version)"

release-package-upload:
	@echo package_tarball=$(package_tarball)
	{ cd $(dir $(package_tarball)); ls; echo gh release upload v$(version) $(notdir $(package_tarball)) --clobber; }

latest_module_release = $(shell gh --repo $(1) release list --json tagName --jq '.[0].tagName')

update:
	@echo checking dependencies for updated versions 
	@$(foreach module,$(rstms_modules),go get $(module)@$(call latest_module_release,$(module));)

clean:
	rm -f $(program) *.core 
	go clean
	rm -rf pub
	rm -f .fmt

sterile: clean
	-go clean -i
	-go clean
	-go clean -cache
	-go clean -modcache
	rm -f go.mod go.sum

dist: build
	./pack

install_dir = tmp
pkg_create_args = -S -v \
 -A $(shell uname -m) \
 -D COMMENT='minimal tls client cert file download client' \
 -D MAINTAINER='Matt Krueger <mkrueger@rstms.net>' \
 -d pkg/DESCR \
 -f pkg/PLIST 


package_dir = pub/OpenBSD/$(shell uname -r)/packages/$(shell uname -m)
release_tag != uname -r | tr -d .
package_tarball = $(package_dir)/$(program)-$(version)v$(release_tag).tgz

installed_binary = /$(install_dir)/$(program)

$(installed_binary): $(program)
	strip $<
	cp $< $@

$(package_tarball): $(installed_binary)
	$(gitclean)
	mkdir -p $(package_dir)
	pkg_create $(pkg_create_args) -p $(install_dir) $@

dev_upload_hostname = zippy.rstms.net
dev_upload_url = https://$(dev_upload_hostname):4443
netboot_upload_url = https://netboot.rstms.net

install: $(installed_binary)

package: $(package_tarball)

upload: .upload

.upload: $(package_tarball)
	boxen dist upload $(netboot_upload_url)/$< $<
	if hostname | grep '^$(dev_upload_hostname)$$'; then \
	  boxen --enable-netboot-server dist upload $(dev_upload_url)/$< $<; \
	fi
	@touch $@

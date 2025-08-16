
latest_release != gh release list --json tagName --jq '.[0].tagName' | tr -d v
version != cat VERSION
gitclean = $(if $(shell git status --porcelain),$(error git status is dirty),$(info git status is clean))

bin = gdl

$(bin): fmt 
	fix go build 

run:
	./$(bin)

fmt:
	fix go fmt ./...

clean:
	go clean
	rm -rf README.md build gdl.tgz

README.md: $(bin)
	echo >$@ "# $(bin)"
	env -i ./$(bin) -help 2>>$@ || true

install:
	go install

dist: $(bin)
	./pack

release:
	$(gitclean) 
	@$(if $(update),gh release delete -y v$(version),)
	gh release create v$(version) --notes "v$(version)"

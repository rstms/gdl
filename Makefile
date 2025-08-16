
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

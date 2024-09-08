
bin = gdl

$(bin): fmt 
	fix go build

run:
	./$(bin)

fmt:
	fix go fmt ./...

clean:
	go clean
	rm README.md

README.md: $(bin)
	echo >$@ "# $(bin)"
	env -i ./$(bin) -help 2>>$@ || true


install:
	strip $(bin)
	install -o root -g wheel -m 0755 ./$(bin) /usr/local/bin/$(bin)


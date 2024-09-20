
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
	install -s -o root -g wheel -m 0755 ./$(bin) /usr/local/bin/$(bin)
	install -s -o _nbd -g www -m 0755 ./$(bin) /var/www/netboot/$(bin)
	./pack
	install -o _nbd -g www -m 0755 ./gdl.tgz /var/www/netboot/gdl.tgz



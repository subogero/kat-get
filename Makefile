start:
	./kat-get -d
cli:
	./kat-get MotoGP
install:
	mkdir /var/lib/kat-get
	cp -r public kat-get kat-get.service /var/lib/kat-get
	ln -s /var/lib/kat-get/kat-get /usr/bin
	systemctl enable /var/lib/kat-get/kat-get.service
	systemctl start kat-get
uninstall:
	-systemctl stop kat-get
	-systemctl disable kat-get
	-rm /usr/bin/kat-get
	-rm -rf /var/lib/kat-get

build:
	@make -f app/Makefile build
	@make -f doh/Makefile build
	@make -f ovpn/Makefile build
	@make -f tor/Makefile build

rmi:
	@make -f app/Makefile rmi || true
	@make -f doh/Makefile rmi || true
	@make -f ovpn/Makefile rmi || true
	@make -f tor/Makefile rmi || true

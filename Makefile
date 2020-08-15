build:
	@cd app && make build
	@cd doh && make build
	@cd ovpn && make build
	@cd tor && make build

rmi:
	@cd app && make rmi
	@cd doh && make rmi
	@cd ovpn && make rmi
	@cd tor && make rmi

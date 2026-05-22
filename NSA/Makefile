.PHONY: up down certs hosts build logs

# Generate self-signed SSL cert for nsa.local
certs: nginx/ssl/cert.pem

nginx/ssl/cert.pem:
	mkdir -p nginx/ssl
	openssl req -x509 -newkey rsa:4096 \
		-keyout nginx/ssl/key.pem \
		-out nginx/ssl/cert.pem \
		-days 365 -nodes \
		-subj "/CN=nsa.test/O=NSA Project"

# Add nsa.local to /etc/hosts (requires sudo)
hosts:
	grep -q "nsa.test" /etc/hosts || \
		echo "127.0.0.1  nsa.test" | sudo tee -a /etc/hosts

build:
	docker compose build

up: certs hosts build
	docker compose up -d
	@echo ""
	@echo "  App:        https://nsa.test:8443"
	@echo "  HTTP→HTTPS: http://nsa.test:8080"
	@echo "  phpMyAdmin: https://nsa.test:8443/phpmyadmin/"
	@echo "  Mail UI:    http://localhost:8025"
	@echo "  Log report: https://nsa.local:8443/logs/"
	@echo ""

down:
	docker compose down

logs:
	docker compose logs -f webapp1 webapp2

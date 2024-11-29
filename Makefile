run-dev:
	docker compose up -d

run-prod:
	docker compose -f docker-compose.prod.yml up --build

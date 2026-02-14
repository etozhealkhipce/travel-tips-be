.PHONY: dev down

dev:
	docker-compose up -d strapiDB
	npm run develop

down:
	docker-compose down

reset:
	docker-compose down -v
	docker-compose up -d database
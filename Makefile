.PHONY: dev down

dev:
	docker-compose up -d strapiDB
	npm run develop

down:
	docker-compose down

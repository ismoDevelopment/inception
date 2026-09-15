compose_file := ./srcs/docker-compose.yml

all: pull up

init:
	cp -r /home/ismo/data/secrets ./secrets
	cp /home/ismo/data/.env ./srcs/.env

pull:
	docker compose -f $(compose_file) pull

up:
	docker compose -f $(compose_file) up --build --remove-orphans -d

down:
	docker compose -f $(compose_file) down

clean: down
	docker compose -f $(compose_file) down -v
	# rm -rf ./secrets .env

fclean: clean
	docker system prune -f
	rm -rf ./secrets
	rm -f ./srcs/.env
	
.PHONY: init pull up all clean fclean restart
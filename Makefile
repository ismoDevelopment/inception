compose_file := ./srcs/docker-compose.yml

volume_dir := /home/benne/data

all: init pull up

init:
	cp -r $(volume_dir)/secrets ./secrets
	cp $(volume_dir)/.env ./srcs/.env

pull:
	docker compose -f $(compose_file) pull

up:
	docker compose -f $(compose_file) up --build --remove-orphans -d

down:
	docker compose -f $(compose_file) down

clean: down
	docker compose -f $(compose_file) down -v

fclean: clean
	docker system prune -f
	rm -rf ./secrets
	rm -f ./srcs/.env

re: fclean all

.PHONY: init pull up all clean fclean restart re

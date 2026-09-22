include /home/ismo/data/.env

compose_file := ./srcs/docker-compose.yml

all: init pull up

init:
	rm -rf ./secrets
	rm -f ./srcs/.env
	cp -r $(DATA_FOLDER)/secrets ./secrets
	cp $(DATA_FOLDER)/.env ./srcs/.env

pull:
	docker compose -f $(compose_file) pull

up:
	docker compose -f $(compose_file) up --build --remove-orphans -d

down:
	docker compose -f $(compose_file) down

clean:
	docker compose -f $(compose_file) down -v --rmi all

fclean: clean
	rm -rf ./secrets
	rm -f ./srcs/.env

re: fclean all

.PHONY: init pull up all down clean fclean re

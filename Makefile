compose_file := ./srcs/docker-compose.yml

volume_dir := /home/benne/data

all: init pull up

init:
	mkdir -p $(volume_dir)/wordpress
	mkdir -p $(volume_dir)/mariadb
	rm -rf ./secrets
	rm -f ./srcs/.env
	cp -r $(volume_dir)/secrets ./secrets
	cp $(volume_dir)/.env ./srcs/.env

pull:
	docker compose -f $(compose_file) pull

up:
	docker compose -f $(compose_file) up --build --remove-orphans -d

clean:
	docker compose -f $(compose_file) down -v

fclean: clean
	docker compose -f $(compose_file) down -v --rmi all
	sudo rm -rf $(volume_dir)/wordpress $(volume_dir)/mariadb ./secrets
	sudo rm -f ./srcs/.env

re: fclean all

.PHONY: init pull up all clean fclean re

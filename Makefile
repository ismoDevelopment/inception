data_folder := /home/$(USER)/data
compose_file := ./srcs/docker-compose.yml

all: init pull up

init:
	mkdir -p ./secrets
	printf '%s' $$(openssl rand -base64 24) > ./secrets/db_password.txt
	printf '%s' $$(openssl rand -base64 24) > ./secrets/db_root_password.txt
	printf '%s' $$(openssl rand -base64 24) > ./secrets/wp_admin_password.txt
	printf '%s' $$(openssl rand -base64 24) > ./secrets/wp_user_password.txt
	cp $(data_folder)/.env ./srcs/.env

up:
	mkdir -p $(data_folder)/wordpress
	mkdir -p $(data_folder)/mariadb
	docker compose -f $(compose_file) up --build --remove-orphans -d

down:
	docker compose -f $(compose_file) down

clean:
	docker compose -f $(compose_file) down -v

fclean: clean
	sudo rm -rf $(data_folder)/wordpress $(data_folder)/mariadb
	rm -rf ./secrets
	rm -f ./srcs/.env

re: fclean all

.PHONY: init pull up all down clean fclean re

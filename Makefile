# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: uahmed <uahmed@student.hive.fi>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/07/14 20:03:19 by uahmed            #+#    #+#              #
#    Updated: 2024/07/14 20:03:27 by uahmed           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOCKER-COMPOSE := ./srcs/docker-compose.yml
DATADIR	       := ~/data

RM          :=  rm -rf
SCREENCLR   :=  printf "\033c"
SLEEP       :=  sleep .1

F           =   =====================================
B           =   \033[1m
T           =   \033[0m
G           =   \033[32m
V           =   \033[35m
C           =   \033[36m
R           =   \033[31m
Y           =   \033[33m

all: title volumes up

volumes:
	@mkdir -p ~/data/mariadb-volume
	@mkdir -p ~/data/wordpress-volume

up: volumes
	@docker compose -f $(DOCKER-COMPOSE) up -d --build
	@make finish

down:
	@docker compose -f $(DOCKER-COMPOSE) down

clean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) || true

clean-locally:
	@$(RM) $(DATADIR)

re: down up

consent:
	@read -p "CRITICAL: Are you sure do you want to delete all data? ACTION is IRREVERSIBLE. [y/N]" confirm; \
		if [ "$$confirm" = "y"]; then \
			echo "Cleaning Docker data..."; \
		else \
			echo "Cleaning data cancelled..."; \
			exit 1; \
		fi
title:
	@$(SCREENCLR) && printf "\n"
	@printf "$(C)╦╔╗╦╔═╗╔═╗╔═╗╔═╦═╗╦╔═╗╔╗╦$(T)\n"
	@printf "$(C)║║║║║  ║═ ║═╝  ║  ║║ ║║║║$(T)\n"
	@printf "$(C)╩╩╚╝╚═╝╚═╝╩    ╩  ╩╚═╝╩╚╝  by uahmed$(T)\n"
	@printf "$(G)$(B)$(F)\n$(T)\n"

finish:
	@printf "\n$(G)$(B)$(F)$(T)\n"
	@printf "$(C)╔═╗╦╔╗╔╦╔═╗╦ ╦╔═╗╔╦╗        $(V)$(B)$(NAME)$(T)\n"
	@printf "$(C)╠╣ ║║║║║╚═╗╠═╣║╣  ║║$(T)\n"
	@printf "$(C)╚  ╩╝╚╝╩╚═╝╩ ╩╚═╝═╩╝$(T)\n\n"

.PHONY: all up down re clean clean-locally volume consent

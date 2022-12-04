SHELL := /bin/bash

include ./.env

help: ## Ayudita.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

__delete_links:
	@sudo rm -f ./IS-IN-MODE-*
	@sudo rm -f docker-compose.yml

__set_dev_links:
	@sudo ln -s docker-compose-dev.yml docker-compose.yml
	@sudo touch IS-IN-MODE-DEV

__set_prod_links:
	@sudo ln -s docker-compose-prod.yml docker-compose.yml
	@sudo touch IS-IN-MODE-PROD

start: ## docker-compose start
	@docker-compose start

stop: ## docker-compose stop
	@docker-compose stop

up: ## docker-compose up (adjunta automaticamente docker-compose-traefik.yml)
	@[ -f docker-compose-traefik.yml ] && docker-compose -f docker-compose.yml -f docker-compose-traefik.yml up || docker-compose up

down: ## docker-compose down
	@docker-compose down

up_build: ## docker-compose up --build
	@docker-compose up --build

ps: ## docker-compose ps
	@docker-compose ps

log: ## docker-compose logs -f --tail=1000
	@docker-compose logs -f --tail=1000

dev: ## compilar y arrancar como dev
dev: down __delete_links __set_dev_links up

prod: ## compilar y arrancar como prod
prod: down __delete_links __set_prod_links up

django_bash: ## Bash en contenedor django como user django
	@docker exec -u django -ti ${CONTAINER_NAME}_django bash

django_bash_root: ## Bash en contenedor django como user root
	@docker exec -u root -ti ${CONTAINER_NAME}_django bash

django_shell: ## Shell django en el contenedor de django
	@docker exec -u django -ti ${CONTAINER_NAME}_django /srv/project/manage.py shell

django_jupyter: ## Inicia instancia de jupyter
	@docker exec -u django -ti ${CONTAINER_NAME}_django /srv/project/manage.py shell_plus --notebook

django_create_superuser: ## manage.py createsuperuser en contenedor de django
	@docker exec -u root -ti ${CONTAINER_NAME}_django /srv/project/manage.py createsuperuser

django_git_pull: ## volumes/django/git pull
	@git -C ./volumes/django pull

django_git_pull_force: ## volumes/django/git pull --force
	@git -C ./volumes/django pull

django_git_reset: ## volumes/django/git reset --hard origin/master
	@git -C ./volumes/django reset --hard origin/master

django_migrations_remove: ## Borrar los ficheros migrations de todos los modelos de django
	@sudo find . -path "./volumes/django/apps/migrations/*.py" -not -name "__init__.py" -delete
	@sudo find . -path "./volumes/django/apps/migrations/*.pyc" -delete

django_migrations_start: ## Crear migrations --fake-inital
	@docker exec -u root -ti ${CONTAINER_NAME}_django bash auto_start_migrate/start_migrates.sh

django_graph_models:  ## Crear fichero myapp_models.png con la relación de modelos
	@docker exec -u root -ti ${CONTAINER_NAME}_django /srv/project/manage.py graph_models -a -o /srv/project/myapp_models.png

postgres_bash: ## Bash en contenedor postgresql como user postgres
	@docker exec -u postgres -ti ${CONTAINER_NAME}_db bash

postgres_shell: ## Bash en contenedor postgresql como user postgres
	@docker exec -u postgres -ti ${CONTAINER_NAME}_db psql

postgres_backup: ## Backup de postgerss (tar.gz)
	@sudo tar cvfz ./db.tar.gz ./volumes/db-data-psql

redis_bash: ## Bash en contenedor redis como user root
	@docker exec -u root -ti ${CONTAINER_NAME}_redis bash

redis_monitor: ## Bash Monitor
	@docker exec -u root -ti ${CONTAINER_NAME}_redis redis-cli monitor

redis_clear: ## Redish borrar cache en volumes/redis/*
	@docker exec -u root -ti ${CONTAINER_NAME}_redis redis-cli FLUSHALL
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "Reinicia este docker, a veces la cache de redis persiste en la ram"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

fix_folders_permissions: ## Arreglar permisos en carpetas
	sudo chown ${USER} -R ./volumes/django
	sudo find ./volumes/django -type d -exec chmod 775 {} \;
	sudo find ./volumes/django -type f -exec chmod 674 {} \;
	sudo find ./volumes/django -type d -name \* -exec chmod 775 {} \;
	sudo find ./volumes/django -type f -iname "*.sh" -exec chmod 777 {} \;
	sudo find ./volumes/django -type f -iname "manage.py" -exec chmod 777 {} \;
	@echo ""
	@echo "es aconsejable hacer chown {tu_user} -R ./volumes/django"

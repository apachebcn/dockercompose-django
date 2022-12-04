# Docker compose para Django.Desarrollo y Producción

Por Pedro Reina Rojas (apachebcn@gmail.com)



## Características

Características para el entorno Docker:

- Python 3.7 (Seleccionable desde Dockerfile)
- Django 3.2 (Seleccionable desde requirements.txt)
- PostgreSql 12.3 (Seleccionable desde docker-compose)
- Redis
- Jupyter
- DevContainer
- docker-compose-traefik.yml es detectado y ejecutado automáticamente vía Makefile
- PgAdmin 4 (opcional desde docker-compose-pgadmin)
- Cambio automático entre DEV/PROD desde comando Makefile
- docker-compose  independiente para los modos Dev/Prod
- Iniciador migrations Django (desde make django_migrations_start)
- Adicionador rápido de paquetes debian en /bin/config/install_customs_apt.sh
- Adicionador rápido de paquetes python en /bin/config/install_customs_pip.sh
- Entrada rápida a bash-contenedor y a Django-shell (desde Makefile)
- Ayuda rápida para git pull y git reset del proyecto Django (desde Makefile)
- Vaiables debug, debug_toolbar y debug_ptvsd desde .env



Características para el proyecto Django:

- [x] Ejemplo inicial en volumes/django_default, para copiar o linkar
- [x] Wsgi
- [x] Gettext
- [x] Admin Honey Pot
- [x] Preconfiguración de Flake8 para Visual studio Code
- [x] Django extensions 
- [x] Redis
- [x] DebugBarTool configurado para modo Dev
- [x] Ptvsd configurado para modo Dev y para devcontainer
- [x] Werkzeug configurado sin Pin para modo Dev
- [x] Nginx configurado para modo Prod
- [x] Extensiones Visual Studio Code desde carpeta .vscode y desde .devcontainer
- [x] Configuraciones Visual Studio Code desde carpeta .vscode y desde .devcontainer



## ¿Por que Django en Docker

Porque Docker nos permite una gran movilidad, simpliciad, y rapidez en el despliegue de nuestros proyectos en cualquier servidor.<br>
También nos simplifica el hacer un backup de todo el entorno, o clonarlo en cualquier lugar (Proyecto, configuración, base de datos, y todo el entorno completo)



## Presentación

Este diseño promueve la rápida conmutación entre los modos **DEV** y **PROD**.<br>
**Dev** funciona directamente con django como servidor con runserver_plus escuchando en puerto 8000 (para testeo y debug)<br>
**Prod** funciona con django-uwsgi escuchando con puerto 8000 con Nginx como puerto reverso. (para entorno de producción)<br>

El comando que se ejecuta en consola desde la raiz del proyectp,  **make dev** y **make prod**, conmutan estos 2 modos sin necesidad de recompilar la imagen.<br>
En esta conmutación automática se crean los enlaces (links) .env y .docker-compose.yml que apuntan a los ficheros correctos según el modo seleccionado.<br>
Y al mismo tiempo se genera un link, **IS-IN-MODE-DEV** o **IS-IN-MODE-PROD**, para dejar como testigo visual cual es el modo seleccionado actual.<br>

Ejemplo

![image-20221203214343995](readme_img/image-20221203214343995.png)



## Iniciar proyecto

### Configurar el entorno🔧

#### bin/dockerfile

Abrimos **bin/dockerfile** y en la linea nº1 especificamos la versión de python.

#### bin/config

Abrimos **bin/config/requirements.txt** y especificamos las versiones de:

```
django==3.2.15
uwsgi==2.0.17.1
psycopg2-binary==2.8.5
flake8==3.2.1
```

Creamos o editamos los ficheros para instalaciones adicionales:

- bin/config/install_customs.sh
  - insertamos lineas de apt-get (ejemplo: apt-get install git)

- bin/config/install_pip.sh
  - insertamos lineas de pip o pip 3 install (ejemplo: pip3 install django-forms)

*Estos ficheros están en .gitignore para que el repositorio no lo recoga los cambios producidos por el usuario, ya que estos determinan la configuración local del proyecto del usuario.*<br>
*Así que cuando hagamos un "git pull" a este repositorio, no habrá problemas ni conflictos por los cambios en este fichero.*



#### Entorno Docker (fichero .env)

Abrimos el fichero **.env** (si no existe, lo copiamos de **.env.default**)

Y lo configuramos:

```
COMPOSE_PROJECT_NAME=project_X
CONTAINER_NAME=project_X
DJANGO_HOSTNAME=project_X.localhost

# public postgresql port
EXPOSE_PUBLIC_PORT_DB=8884

# public django ports in dev mode
EXPOSE_PUBLIC_DEV_PORT_DJANGO_RUNSERVER=800
EXPOSE_PUBLIC_DEV_PORT_PTVSD=3002
EXPOSE_PUBLIC_DEV_PORT_DJANGO_JUPITER=8888

# public django ports in prod mode
EXPOSE_PUBLIC_PROD_PORT_NGINX=800
EXPOSE_PUBLIC_PROD_PORT_NGINX_SSL=4430

# postgresql parameters
POSTGRES_VERSION=12.3
DB_ENGINE=django.db.backends.postgresql_psycopg2
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=xxxxxxxx
DB_PORT=5432

# Django settings
DJANGO_DEBUG=False
DJANGO_DEBUG_TOOLBAR=False
DJANGO_PTVSD_DEBUG=False

```

*El último parrafo es atendido por django settings*



#### Entorno Docker (fichero docker-compose)

***Este punto no es necesario tratarlo.<br>
Sólo es a nivel de conocimiento.***

El fichero docker-compose.yml será un link que apunta a docker-compose-dev.yml o docker-compose-prod.yml.<br>
Si no existe este fichero, no te preocupes, se generará solo al arrancar el proyecto con "make dev" o "make prod"<br>
En cualquier caso, **NO EDITES DIRECTAMENTE docker-compose.yml**<br>

Podemos revisar y editar **docker-compose-dev.yml** y **docker-compose-prod.yml**
Pero todo está pensado para no tener que modificar estos ficheros.<br>

Algo muy util en estos ficheros, es la variable MODE, cuyo valor es el modo seleccionado (dev o prod)<br>
Esta variable es visible dentro del entorno Django.<br>
De hecho está usandose en el fichero settings.py

Foto (docker-compose-dev.yml) donde se asigna la variable "MODE" con valor "dev" o "prod"

![image-20221203222431862](readme_img/image-20221203222431862.png)



#### django_default

La carpeta volumes/django_default es un referente necesario para aplicar cosas a tu proyecto inicial Django.<br>
Copia de esta carpeta "django_default" lo que te interese aplicar a tu proyecto, a tu carpeta volumes/django, o también puedes linkarlo.

- **.vscode**<br>
  - Contiene
    - extensions.json: <br>La recomendación de aplicaciones a instalar. (Visual Code te ofrecerá la respectiva sugerencia)
    - launch.json:<br> 2 modos de debug:
      - Debug para el proyecto cargado como carpeta
      - Debug para el proyecto cargado como devcontainer
    - settings.json:<br>Configuración de Visual Code, entre ellos la configuración de Flake8
- **project**<br>
  Ejemplo de la carpeta project donde se encuentra el settings.py, urls.py, etc...<br>
  Cópialo a tu proyecto y personalízalo.<br>
  Este settings está diseñado de tal forma que usa las variables del .env de docker.
- **auto_start_migrate**<br>
  Carpeta necesaria en tu proyecto, para que funcione el comando "make django_migrations_start"



#### django_settings

Todos los proyectos django necesita tener el settings.py configurado para el proyecto, así como la carga de aplicaciones.<br>
Idealmente copiar django_default/project y personalizar.



#### Arrancar docker con django configurado

Simplemente en consola, escribimos:

```
make dev
```

ó

```
make prod
```

ó si ya tienes un modo seleccionado:

```
make up
```



#### Iniciar la base de datos con los modelos del proyecto

Si el proyecto es nuevo, puede que Django haga automaticamente las migraciones de modelos a base de datos.<br>
En algunas ocasiones no lo hace o no lo hace por completo.<br>
Para iniciar las migraciones, usamos el script "auto start migrations"<br>
Ejecutando el comando

```
make django_migrations_start
```



## Comandos make

- make start<br>
  Ejecuta docker-compose start 
- make stop<br>
  Ejecuta docker-compose stop
- make up<br>
  Ejecuta docker-compose up (adjunta automaticamente docker-compose-traefik.yml) 
- make down<br>
  Ejecuta docker-compose down 
- make up_build<br>
  Ejecuta docker-compose up --build 
- make ps<br>
  Ejecuta docker-compose ps 
- make log<br>
  Ejecuta docker-compose logs -f --tail=1000 
- make dev<br>
  Compila y arranca en modo dev 
- make prod<br>
  Compila y arranca en modo prod 
- make django_bash<br>
  Bash en contenedor django como user django 
- make django_bash_root<br>
  Bash en contenedor django como user root 
- make django_shell<br>
  Shell django en el contenedor de django 
- make django_jupyter<br>
  Inicia instancia de Jupyter
- make django_create_superuser<br>
  Ejecuta manage.py createsuperuser en contenedor de django 
- make django_git_pull<br>
  Ejecuta git pull en volumes/django 
- make django_git_pull_force<br>
  Ejecuta git pull --force en volumes/django/git pull 
- make django_git_reset<br>
  Ejecuta git reset --hard origin/master en volumes/django
- make django_migrations_remove<br>
  Borra todos los ficheros migrations de todos los modelos de django 
- make django_migrations_start<br>
  Borra todos los ficheros migrations y recrea nuevamente los migrations/migrate/migratesql de todos los modelos de django 
- make django_graph_models<br>
  Crea el fichero myapp_models.png con la relación de modelos de Django 
- make postgres_bash<br>
  Bash en el contenedor postgresql como user postgres 
- make postgres_shell<br>
  Bash en el contenedor postgresql como user postgres 
- make postgres_backup<br>
  Crea una copia de /volumes/db-data-psql en formato tar.gz 
- make redis_bas<br>
  Bash en el contenedor redis como user root 
- make redis_monitor<br>
  Bash con monitor de redis
- make redis_clear<br>
  Flush cache de Redis 
- make fix_folders_permissions<br>
  Arreglar permisos en carpetas



## Probar Django

Tras levantar el contenedor de docker con **make dev**/**made prod** o  **make up**<br>

Introducimos en el navegador http://locahost:804 (o el puerto que hayamos seleccionado)<br>

Página por defecto de Django

![](./readme_img/django-default-home.png)



## Reiniciar la base de datos

1. Paramos la instancia
2. Borramos el contenido del volumen postgresql
3. Volvemos a levantar el contenedor de docker

Y la base de datos vuelve a crearse de nuevo, pero solo se generan las tablas del entorno de Django, con el sistema de usuarios y el admin.<br>
Las tablas de nuestro proyecto las tenemos que volver a sincronizar con `makemigrations` `migrate` y `sqlmigrate`



## Rutas de imagenes



### static

Almacenamiento de los assets estáticos.<br>
Un asset es el tipo de ficheros que se cargan al navegador, osea, los img, css, js .<br>
En nuestro settings.py bajo el comentario \"# Rutas" veremos las rutas que Django va a usar para la ruta de assets estáticos.<br>

Los assets inicialmente serán para los vendors y subaplicaciones, tal como puede ser debug_toolbar y bootstrap.<br>
Pero también incluiremos aquí los assets de nuestro projecto, podría ser en **volumes/django/assets/static/my.project**<br>
Cuando Django esté en modo **prod**, ejecutará automaticamente `collectstatic`.
`collectstatic` copia la ruta local static a la ruta externa static.<br>
En esta caso de **volumes/django/assets/static** =>**volumes/static**<br>
Lo que llamo ruta externa static es lo que nginx va a usar.<br>
En el caso de que django cargue un asset en modo 'dev' y en modo 'prod' nos devuelva un error 404, probablemente será porque en este static externo no existe físicamente el asset.



### media

**En volumes/django/assets/media**

Lo usaremos para los ficheros que se suben con "upload",  ficheros de usuarios y etc.



## Debug

Y para activar o desactivar Debug, en el fichero .env:

```
DJANGO_DEBUG=True
```



## DebugToolBar

Para activarlo, en el fichero .env:

```
DJANGO_DEBUG_TOOLBAR=True
```



## Debug con Ptvsd

en el fichero .env:

```
DJANGO_PTVSD_DEBUG=True
```

Y reiniciamos el contenedor.

Y en visual code seleccionamos el debuger que nos interesa (foto siguiente)  con el puerto especificado.<br>
Se entiende que remoteRoot (la ruta en el contenedor) es /srv/project, debiendose cambiar si tu proyecto en el contenedor difiere de esta ruta.

![image-20221204032116660](readme_img/image-20221204032116660.png)

Acto seguido y como es popularmente sabido, marcamos los puntos de interrupción en los ficheros, y hacemos click en el icono "play" del debug.



## Jupyter

Jupyter nos permiten 2 cosas muy utiles:

- Navegar por los ficheros de Django como si el contenedor fuese un ftp, y nos permite crear carpetas y subir y editar ficheros.
- Usar un interprete tal como django_bash, pero gráficamente, insertando o pegando varias lineas para ejecutarlo como si fuese un IDE.  

Jupyter se ejecuta gracias a la configuración de Docker, y a unas lineas de especificaciones en project/settings.py
*(En volumes/django_default/project/settings.py podemos encontrar estas lineas bajo el comentario #jupyter)*

Ejecutar en consola en el directorio del proyecto

```
make django_jupyter
```

Deberá aparecer algo así:

![image-20221204033203043](readme_img/image-20221204033203043.png)

Entonces pondremos en el navegador lo que nos indica la consola, siendo el token el que autoriza al navegador a acceder a Jupyter

Y veremos algo tal que así

![image-20221204033901994](readme_img/image-20221204033901994.png)

Haciendo New->Django Shell-Plus abrimos un interprete que estará ejecutando dentro del Django dentro del contenedor, como si Django estuviese en local en nuestra máquina

![image-20221204034112865](readme_img/image-20221204034112865.png)



Al termina el uso con Jupyter, hacemos Ctrl+C en la consola.
![image-20221204034211741](readme_img/image-20221204034211741.png)



## Devcontainer

Devcontainer es una nueva tecnología de Visual Studio Code que ofrece un modo de trabajo bastante interesante.<br>

Para el conocimiento de Devcontainer => https://code.visualstudio.com/docs/devcontainers/containers<br>

El devcontainer configurado en este proyecto es muy básico y simplificado, que nada tiene que ver con las posibilidades que ofrece esta tecnología.<br>

### Como se usa

Abrimos Visual Studio Code y abrimos la carpeta desde la carpeta raiz (el que contiene la carpeta .devcontainer)<br>
También podemos hacer lo mismo desde el explorador de archivos haciendo "abrir con..."<br>

Cuando Visual Studio Code detecta que la carpeta que le estamos pidiendo abrir contiene la carpeta .devcontainer, nos ofrece lo siguiente:

![image-20221204043938698](readme_img/image-20221204043938698.png)

Si hacemos "Reopen in Container" Visual Studio Code se cierra y se abre nuevamente, en modo 'devcontainer'

### Que nos ofrece

Cuando Visual Studio Code se abre en modo 'devcontainer', hace lo siguiente<br>

- Se conecta al contenedor de Django, y la gestion de ficheros y la terminal se ejecuta desde dentro del contenedor, ofreciéndonos los recursos del mismo como si estuviesen en local.<br>
  De hecho, si hacemos un "abrir fichero", no podremos abrir ficheros locales, las rutas mostradas son las del contenedor.
- El devcontainer aplica a nuestro Visual Studio Code las configuraciones visuales y funcionales indicadas en el fichero devcontainer.json
- El devcontainer va a instalar todas las extensiones a nuestro Visual Studio Code (ojo, no son recomendaciones como en un extensions.json, serán instalaciones explicitas)

En conjunto, devcontainer nos ofrece un entorno completo tal como se define en devcontainer.json.<br>

Y el resultado final es como si alguien te estuviese prestando su entorno de trabajo, tal como lo está usando en su día a día.

#!/bin/bash
set -e

if [ $MODE == "prod" ]; then

    echo "*********************************"
    echo "*********************************"
    echo "*********************************"
    echo "*********************************"
    echo "*                               *"
    echo "*     start.sh MODE PROD        *"
    echo "*                               *"
    echo "*********************************"
    echo "*********************************"
    echo "*********************************"
    echo "*********************************"

    chown -R django:django /srv

    echo "==> Django setup, executing: collectstatic"
    python3 /srv/project/manage.py collectstatic --noinput -v 3

    /srv/scripts/start_db.sh

    echo "==> Starting uWSGI ..."
    /usr/local/bin/uwsgi --emperor /etc/uwsgi/django-uwsgi.ini

else

    echo "*********************************
    *********************************
    *********************************
    *********************************
    *                               *
    *      start.sh MODE DEV        *
    *                               *
    *********************************
    *********************************
    *********************************
    *********************************"

    chown -R django:django /srv

    /srv/scripts/start_db.sh

    # opcion --nopin es para que WERKZEUG no pida el pin
    /srv/project/manage.py runserver_plus 0.0.0.0:8000 --nopin --keep-meta-shutdown --insecure

fi


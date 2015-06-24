#!/bin/bash

MODULE=${MODULE:-website}

sed -i "s#module=website.wsgi:application#module=${MODULE}.wsgi:application#g" /opt/django/uwsgi.ini

if [ ! -f "/opt/django/app/manage.py" ]
then
	echo "creating basic django project (module: ${MODULE})"
	django-admin.py startproject ${MODULE} /opt/django/app/
fi

if [ -n "${DJANGO_INIT_SCRIPT}" ] && [ -f "${DJANGO_INIT_SCRIPT}" ];
then
        echo "running init script ${DJANGO_INIT_SCRIPT}"
        (eval "${DJANGO_INIT_SCRIPT}")
fi

/usr/bin/supervisord

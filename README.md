Impulse Cloud Django Docker Image
==================

forked originally from mbentley/docker-django-uwsgi-nginx

docker image for django (uwsgi) & nginx
based off of ubuntu 14.04.2

To pull this image:
`docker pull impulsecloud/ic-django`

Example usage:
`docker run -p 80 -d -e MODULE=myapp DJANGO_INIT_SCRIPT=/opt/django/app/init-docker.sh impulsecloud/ic-django`

You can mount the application volume to run a specific application.  The default volume inside in the container is `/opt/django/app`.  Here is an example:
`docker run -p 80 -d -e MODULE=myapp -v /home/project/myapp:/opt/django/app impulsecloud/ic-django`

Environment Variables
---------------------

**MODULE** - The Django module name

**DJANGO_INIT_SCRIPT** - A script to run when starting up

**PG_ISREADY_URI** - Run pg_isready with this URI before anything else. In other words, wait for the database to be ready and accepting connections.

Typically you will then have your own convention for environment variables used in Django's settings.py such as the DB_URI and DEBUG mode.

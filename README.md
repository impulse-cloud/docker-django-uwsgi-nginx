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


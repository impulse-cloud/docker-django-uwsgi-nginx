FROM impulsecloud/ic-ubuntu:latest

# Forked from https://github.com/mbentley/docker-django-uwsgi-nginx
MAINTAINER Johann du Toity <johann@impulsecloud.com.au>

RUN apt-get update && apt-get install -y \
  nginx \
  supervisor && \
  pip install uwsgi && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /opt/django/

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /opt/django/django.conf /etc/nginx/sites-enabled/
RUN ln -s /opt/django/supervisord.conf /etc/supervisor/conf.d/

VOLUME ["/opt/django/app"]
EXPOSE 80
CMD ["/opt/django/run.sh"]

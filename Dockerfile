FROM impulsecloud/ic-ubuntu:latest

# Forked from https://github.com/mbentley/docker-django-uwsgi-nginx
MAINTAINER Johann du Toity <johann@impulsecloud.com.au>

RUN apt-get update && apt-get install -y \
  nginx \
  supervisor && \
  pip install uwsgi && \
  pip install lxml && \
  pip install Pillow && \
  pip install SQLAlchemy && \
  pip install psycopg2 && \
  pip install pycrypto && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /opt/django/

RUN echo "daemon off;" >> /etc/nginx/nginx.conf; \
    rm /etc/nginx/sites-enabled/default; \
    ln -s /opt/django/django.conf /etc/nginx/sites-enabled/; \
    ln -s /opt/django/supervisord.conf /etc/supervisor/conf.d/; \
    sed -i "s#/var/log/nginx/access.log#/dev/stdout#g" /etc/nginx/nginx.conf; \
    sed -i "s#/var/log/nginx/error.log#/dev/stdout#g" /etc/nginx/nginx.conf

VOLUME ["/opt/django/app"]
EXPOSE 80
CMD ["/opt/django/run.sh"]

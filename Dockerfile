FROM impulsecloud/ic-ubuntu:18.04

# Forked from https://github.com/mbentley/docker-django-uwsgi-nginx
MAINTAINER Johann du Toit <johann@impulsecloud.com.au>

RUN apt-get update && \
  apt-get install -y \
    dumb-init \
    gettext \
    nginx \
    python3-venv \
    supervisor && \
  pip3 install uwsgi && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./install_singer.sh /root/singer/
COPY ./singer-connectors /root/singer/singer-connectors
RUN ls -al /root/singer/singer-connectors/
RUN /root/singer/install_singer.sh && rm -rf /root/singer

ADD ./requirements.txt /opt/django/

RUN pip3 install --exists-action=s -r /opt/django/requirements.txt

ADD . /opt/django/

RUN echo "daemon off;" >> /etc/nginx/nginx.conf; \
    rm /etc/nginx/sites-enabled/default; \
    ln -s /opt/django/django.conf /etc/nginx/sites-enabled/; \
    ln -s /opt/django/status.conf /etc/nginx/sites-enabled/; \
    ln -s /opt/django/supervisord.conf /etc/supervisor/conf.d/; \
    sed -i "s#/var/log/nginx/access.log#/dev/stdout#g" /etc/nginx/nginx.conf; \
    sed -i "s#/var/log/nginx/error.log#/dev/stdout#g" /etc/nginx/nginx.conf

VOLUME ["/opt/django/app"]
EXPOSE 80

# Runs the CMD prefixed with "/usr/bin/dumb-init --"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/django/run.sh"]


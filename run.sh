#!/bin/bash

set -o verbose

function clean_stop {
  /usr/bin/supervisorctl stop nginx
  /usr/bin/supervisorctl stop uwsgi
  exit
}

# Docker will send TERM when it's time to shutdown
trap clean_stop SIGTERM

# See if we need to wait on any databases
if [ -n "${PG_ISREADY_URI}" ];
then
  until pg_isready -d ${PG_ISREADY_URI}
  do
    sleep 5
  done
fi

if [ -n "${SSH_KEY}" ];
then
  mkdir -p /root/.ssh
  echo "${SSH_KEY}" | base64 --decode > /root/.ssh/id_rsa
  chmod 700 /root/.ssh/id_rsa
  echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
fi

if [ -z "${GIT_TREEISH}" ];
then
  GIT_TREEISH=HEAD
fi

if [ -n "${GIT_SSH_REPO}" ];
then
  cd /opt/django/app/
  rm -rf *
  git archive --format=tar --remote=${GIT_SSH_REPO} ${GIT_TREEISH} | tar xf -
fi

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

/usr/bin/supervisord &
wait

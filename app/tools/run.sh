#!/usr/bin/env bash

set -o errexit

echo "Making staticfiles"
python manage.py collectstatic --noinput
echo "starting tests..1"
python manage.py create_roles
echo "Initializing database"
python manage.py wait_for_db
python manage.py migrate
python manage.py create_roles

if [[ -n "${ADMIN_USERNAME}" ]] && [[ -n "${ADMIN_PASSWORD}" ]] && [[ -n "${ADMIN_EMAIL}" ]]; then
  python manage.py create_admin \
    --username "${ADMIN_USERNAME}" \
    --password "${ADMIN_PASSWORD}" \
    --email "${ADMIN_EMAIL}" \
    --noinput \
  || true
fi
echo "starting tests..2"
python manage.py create_roles
echo "Starting django"
gunicorn --bind 0.0.0.0:8000 app.wsgi --timeout 300

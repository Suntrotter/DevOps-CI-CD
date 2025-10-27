FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ../requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

RUN printf '#!/bin/sh\n\
set -e\n\
host="$POSTGRES_HOST"\n\
port="$POSTGRES_PORT"\n\
echo "Waiting for Postgres at $host:$port..."\n\
until nc -z "$host" "$port"; do\n\
  sleep 1\n\
done\n\
echo "Postgres is up!"\n\
exec "$@"\n' > /usr/local/bin/wait-for-db.sh && \
    chmod +x /usr/local/bin/wait-for-db.sh

CMD ["sh", "-c", "python manage.py collectstatic --noinput && \
                   python manage.py migrate && \
                   gunicorn mysite.wsgi:application --bind 0.0.0.0:8000 --workers 3"]

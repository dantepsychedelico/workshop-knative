FROM python:3.7-slim

WORKDIR /usr/src

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r ./requirements.txt

COPY src /usr/src/app

CMD exec gunicorn -b :$PORT -w 1 --threads 8 --access-logfile=- app.app:app

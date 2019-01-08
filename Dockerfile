FROM python:2.7

RUN apt-get update
RUN apt-get install -qy mysql-client

RUN pip install pipenv

WORKDIR ./app/

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --deploy

COPY . .
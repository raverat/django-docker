FROM python:2.7

RUN pip install pipenv

WORKDIR ./app/

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --deploy

COPY . .
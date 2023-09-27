FROM thevlang/vlang:latest

WORKDIR /app

COPY src/main.v .
COPY var/rinha/source.rinha.json /var/rinha/source.rinha.json

RUN v -prod -o main main.v

COPY ./var/rinha/source.rinha.json /var/rinha/source.rinha.json

CMD ["./main", "/var/rinha/source.rinha.json"]
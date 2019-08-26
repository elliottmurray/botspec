FROM ruby:2.4-alpine AS base


ENV GEM_HOME="/usr/local/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN mkdir /app
RUN mkdir /app/bot

WORKDIR /app/bot

COPY ./ /app/bot
COPY botspec.sh /app/bot/

RUN apk update && apk add  --no-cache git make gcc libc-dev

ENV SPEC_PATH=$SPEC_PATH

RUN bundle install

ENTRYPOINT ["sh"]


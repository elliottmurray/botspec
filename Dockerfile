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

RUN gem install bundler -v 2.0.2

RUN bundle install --verbose
RUN bundle exec thor install lib/cli.rb --as botspec --force

CMD ['verify', '-f', 'specs/*', '-n', 'UNNAMED bot'']
ENTRYPOINT ["bundle", "exec", "botspec"]


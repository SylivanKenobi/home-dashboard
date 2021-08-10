FROM registry.puzzle.ch/docker.io/ruby:2.7.2-slim

USER root

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1 && \
    apt-get update && \
    apt-get upgrade -yq && \
    apt-get install -yq nodejs build-essential

WORKDIR /usr/src/app

COPY app/ .

RUN bundle install

USER 1001

EXPOSE 3030

CMD ["smashing", "start", "-p", "3030", "-e", "production"]

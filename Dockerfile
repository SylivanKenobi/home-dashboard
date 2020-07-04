FROM ruby:2.7

# throw errors if Gemfile has been modified since Gemfile.lock

RUN bundle config --global frozen 1
RUN apt-get update
RUN apt-get upgrade -yq
RUN apt-get install -yq nodejs

WORKDIR /usr/src/app

COPY app/ .

RUN bundle install

EXPOSE 3030

CMD ["smashing", "start", "-p", "3030"]

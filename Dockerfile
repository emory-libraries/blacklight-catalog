ARG RUBY_VERSION=3.1.4

FROM ruby:$RUBY_VERSION-bookworm

RUN apt-get update -qq && \
    apt-get install -y \
    nodejs \
    npm

RUN mkdir /app
WORKDIR /app

RUN npm install --global yarn

RUN gem update --system && \
  gem install bundler && \
  bundle config build.nokogiri --use-system-libraries

COPY . .

ENTRYPOINT ["./entrypoint.sh"]
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]

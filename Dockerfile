FROM ruby:3.1
COPY . .
RUN bundle install
CMD bundle exec ruby src/forumlancer.rb

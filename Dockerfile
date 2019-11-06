# gets the docker image of ruby 2.5 and lets us build on top of that
FROM ruby:2.6.5-slim

# install rails dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client && apt-get install -y git

# create a folder /FlexUOMConverter in the docker container and go into that folder
RUN mkdir /touchpoints
WORKDIR /touchpoints

# Copy the Gemfile and Gemfile.lock from app root directory into the /myapp/ folder in the docker container
COPY Gemfile /touchpoints/Gemfile

# Run bundle install to install gems inside the gemfile
RUN bundle install


# Copy the whole app
COPY . /touchpoints

RUN cd /touchpoints

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["rails", "server", "-b", "0.0.0.0"]

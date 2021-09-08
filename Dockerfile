# gets the docker image of ruby 2.5 and lets us build on top of that
FROM ruby:2.7.4

# install rails dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client && apt-get install -y git

# create a folder /FlexUOMConverter in the docker container and go into that folder
RUN mkdir /touchpoints
WORKDIR /touchpoints

# Copy the Gemfile and Gemfile.lock from app root directory into the /myapp/ folder in the docker container
COPY Gemfile /touchpoints/Gemfile
COPY Gemfile.lock  /touchpoints/Gemfile.lock

# Run bundle install to install gems inside the gemfile
RUN cd /touchpoints
RUN gem install bundler && bundle install

# Copy the whole app
COPY . /touchpoints

# Install Yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Run yarn install to install JavaScript dependencies.
RUN yarn install --check-files

# Expose port 3002 to the Docker host, so we can access it
# from the outside.
EXPOSE 3002

# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ./docker-entrypoint.sh 3002

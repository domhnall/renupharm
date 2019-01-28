# Base image
FROM ruby:2.5.3

# Setup environment variables that will be available to the instance
ENV APP_HOME /production

# Installatipt-get install -yon of dependencies
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update -qq \
  && apt-get install -y \
      # Needed for certain gems
    build-essential \
      # Needed for mysql connection
    mysql-client \
      # Needed for asset compilation
    nodejs \
   # Install yarn
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
    # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt \
    /var/lib/dpkg \
    /var/lib/cache \
    /var/lib/log


ENV PATH="/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:${PATH}"

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile
# and install gems
ADD Gemfile* $APP_HOME/
RUN bundle install

# Copy over our application code
ADD . $APP_HOME/

# Install npm packages
#ADD package.json yarn.lock $APP_HOME/
#RUN yarn install
RUN RAILS_ENV=production bin/rails assets:precompile

# Run our app
CMD bundle exec rails s -p ${PORT} -b '0.0.0.0'

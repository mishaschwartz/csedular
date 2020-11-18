# CSeduler

A simple scheduling application.

#### Requirements:

- Postgresql (version 10+ recommended)
- Node and Yarn (latest versions recommended)
- Rails (version 6+ recommended)
- Ruby (version 2.5+ recommended)
- HTTP server (production only, ex: Apache2)

#### Installation:

This installation guide assumes an ubuntu 18.04 server however CSeduler may be installed on a variety of different OSs.
Please adjust the instructions below as required for your environment.

1. Install system dependencies:

```shell script
apt-get update
curl -sL https://deb.nodesource.com/setup_9.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get install postgresql postgresql-client libpq-dev nodejs yarn ruby2.5 ruby2.5-dev
```

2. Install rails dependencies (bundler):

```shell script
gem update --system
update-alternatives --config ruby
update-alternatives --config gem
gem install bundler
```

3. setup postgres database

```shell script
# replace 'password' with a strong password and remember it for later
sudo -u postgres psql -U postgres -d postgres -c "create role cseduler createdb login password 'password';"
/etc/init.d/postgresql restart
```

3. clone CSeduler source code and install dependencies: 

```shell script
git clone https://github.com/mishaschwartz/cseduler.git /cseduler
cd /cseduler
bundle install
yarn install
```

4. start it up!

In development:
```shell script
RAILS_ENV=development ./bin/webpack-dev-server
# replace password with the one you set in step 3
RAILS_ENV=development CSEDULER_DATABASE_PASSWORD='password' bundle exec rails server
```

In production (assumes you have an HTTP server running and configured <- not covered in this guide):
```shell script
RAILS_ENV=production bundle exec rails assets:precompile
# replace password with the one you set in step 3
RAILS_ENV=production CSEDULER_DATABASE_PASSWORD='password' bundle exec rails server
```

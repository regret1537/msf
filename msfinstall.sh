#!/bin/bash
# Metasploit dependencies
sudo apt-get install gpgv2 autoconf bison build-essential curl git-core libapr1 libaprutil1 libcurl4-openssl-dev libgmp3-dev libpcap-dev libpq-dev libreadline6-dev libsqlite3-dev libssl-dev libsvn1 libtool libxml2 libxml2-dev libxslt-dev libyaml-dev locate ncurses-dev openssl postgresql postgresql-contrib wget xsel zlib1g zlib1g-dev

# Configure postgres db
sudo -u postgres createuser msfuser -S -R
sudo -u postgres createdb msfdb -O msfuser
update-rc.d postgresql enable

# Install and configure rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
rvm --install .ruby-version

# Download and install msf
git clone https://github.com/rapid7/metasploit-framework.git
cd metasploit-framework/
gem install bundler
bundle install

# Configure metasploit and postgres
cd ~/.msf4/
touch database.yml
/bin/echo -ne "# Development Database
development: &pgsql
  adapter: postgresql
  database: msfdb
  username: msfuser
  password: [PASSWORD]
  host: localhost
  port: 5432
  pool: 5
  timeout: 5

# Production database -- same as dev
production: &production
  <<: *pgsql

# Test database -- not the same, since it gets dropped all the time
test:
  <<: *pgsql
  database: msfdb" > database.yml

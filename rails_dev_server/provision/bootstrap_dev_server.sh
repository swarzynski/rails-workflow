export DEBIAN_FRONTEND=noninteractive
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install build-essential

# potrzebne dla kompilacji ruby
sudo aptitude -y install libffi-dev libreadline-dev

sudo aptitude -y install unattended-upgrades mc

sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo aptitude update
sudo aptitude -y upgrade

sudo aptitude install -y ruby2.2 ruby2.2-dev
sudo aptitude install -y ruby-switch

sudo ruby-switch --set ruby2.2

echo "gem: --no-document" > ~/.gemrc

#Postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install postgresql-9.4 postgresql-9.4-postgis-2.1 postgresql-contrib

sudo aptitude -y install libsqlite3-dev sqlite3

#wymagane przez rails
sudo aptitude -y install zlib1g-dev libpq-dev

PASS=vagrant
sudo -u postgres psql -c "CREATE USER vagrant WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;"
echo "export DATABASE_USER_PASSWORD=$PASS" >> ~/.profile

sudo -u postgres psql -c "ALTER ROLE vagrant WITH SUPERUSER;"

# Change configuration of PostgreSQL to get access to the database from host machine
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.4/main/postgresql.conf
echo "host all all all md5" | sudo tee --append /etc/postgresql/9.4/main/pg_hba.conf > /dev/null

#odkomentowanie capistrano w Gem
#cap install w projekcie

#libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
#curl #już jest

sudo gem install bundler

echo "alias be='bundle exec'" >> ~/.bashrc

sudo halt

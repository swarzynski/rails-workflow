echo "Europe/Warsaw" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install unattended-upgrades mc


#tylko gdy nie działa apt-add-repository - wersja Ubuntu Server ponoć
#sudo aptitude -y install software-properties-common

sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo aptitude update
sudo aptitude -y upgrade

sudo aptitude install -y ruby2.0 ruby2.0-dev
sudo aptitude install -y ruby-switch

sudo ruby-switch --set ruby2.0

#Postgres
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install postgresql-9.4 postgresql-9.4-postgis-2.1 postgresql-contrib


# Install Phusion's PGP key to verify packages
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

# Add HTTPS support to APT
sudo aptitude -y install apt-transport-https

# Add the passenger repository
sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list"
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
sudo aptitude update

# Install nginx and passenger
sudo aptitude -y install nginx-full passenger

echo "gem: --no-document" > ~/.gemrc

sudo aptitude -y install git-core build-essential
sudo aptitude -y install libsqlite3-dev sqlite3

#wymagane przez rails
sudo aptitude -y install zlib1g-dev libpq-dev

sudo gem install bundler

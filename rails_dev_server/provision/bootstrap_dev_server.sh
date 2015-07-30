sudo aptitude update
sudo aptitude -y upgrade
sudo aptitude -y install unattended-upgrades mc

sudo apt-add-repository -y ppa:brightbox/ruby-ng

sudo aptitude update
sudo aptitude -y upgrade

sudo aptitude install -y ruby2.0 ruby2.0-dev
sudo aptitude install -y ruby-switch

sudo ruby-switch --set ruby2.0


echo "gem: --no-document" > ~/.gemrc

sudo aptitude -y install build-essential
sudo aptitude -y install libsqlite3-dev sqlite3

#wymagane przez rails
sudo aptitude -y install zlib1g-dev libpq-dev

#odkomentowanie capistrano w Gem
#cap install w projekcie

#libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
#curl #już jest

sudo gem install rails

sudo reboot

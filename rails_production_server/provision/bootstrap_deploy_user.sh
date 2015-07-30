sudo service nginx stop
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo cp default /etc/nginx/sites-available/default
sudo service nginx start

mkdir dbbackup
chmod a+x ~/backup_db.sh
echo "1  0   * * *   deploy    /home/deploy/dbbackup.sh" | sudo tee --append /etc/crontab > /dev/null

## postgres 

USER=`whoami`
PASS=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`

sudo -u postgres psql -c "CREATE USER $USER WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;"

echo "export DATABASE_USER_PASSWORD=$PASS" >> ~/.profile
echo "export RAILS_ENV=production" >> ~/.profile

SECRET=`ruby -e "require 'securerandom'; print SecureRandom.hex(64);"`
echo "export SECRET_KEY_BASE=$SECRET" >> ~/.profile
## postgres 

USER=`whoami`
PASS=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`

sudo -u postgres psql -c "CREATE USER $USER WITH ENCRYPTED PASSWORD '$PASS' CREATEDB NOCREATEROLE NOCREATEUSER;"

echo "export DATABASE_USER_PASSWORD=$PASS" >> ~/.profile
echo "export RAILS_ENV=staging" >> ~/.profile

SECRET=`ruby -e "require 'securerandom'; print SecureRandom.hex(64);"`
echo "export SECRET_KEY_BASE=$SECRET" >> ~/.profile

cat ~/.ssh/id_rsa.pub | sudo -H -u deploy tee --append /home/deploy/.ssh/authorized_keys > /dev/null
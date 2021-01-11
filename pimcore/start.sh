#/bin/bash

for filename in build_env/*.sh; do
    source $filename
done

tput setaf 3
tput bold
echo "Starting Pimcore ...."
tput setaf 6
echo "Syncing Code ...."
tput sgr0
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  pimcore_user="www-data"
  sudo rsync -rt --keep-dirlinks --rsync-path="sudo -u $pimcore_user rsync" --links --progress --chown=$pimcore_user:$pimcore_user --chmod=777 -r code/seller-service/* /var/www/html/pimcore/
  sudo -H -u $pimcore_user bash -c "cp $myapp_dev_path/pimcore/var/config/system.php /var/www/html/pimcore/var/config/"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  pimcore_user="_www"
  sudo rsync -rt --keep-dirlinks --perms --chmod=u=rwx,go=rx --owner=_www --group=_www -r $myapp_dev_path/code/seller-service/* /var/www/html/pimcore/
  sudo cp $myapp_dev_path/pimcore/var/config/system.php /var/www/html/pimcore/var/config/
fi

# sudo -H -u $pimcore_user bash -c "cp $myapp_dev_path/pimcore/var/config/system.php /var/www/html/pimcore/var/config/"


sudo chown -R $pimcore_user /var/www/html/pimcore
sudo chmod -R 777 /var/www/html/pimcore

# sudo -H -u $pimcore_user bash -c "cp $myapp_dev_path/pimcore/var/config/system.php /var/www/html/pimcore/var/config/"

if [ -f /var/www/html/pimcore/app/constants.php ]; then

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo sed -i "/'port' =>/c\'port' => \['81', true\]," /var/www/html/pimcore/app/constants.php
    sudo sed -i "/'homePageUrl' =>/c\'homePageUrl' => 'http://localhost:81/admin/login'," /var/www/html/pimcore/app/constants.php
    sudo sed -i "/'statusPageUrl' =>/c\'statusPageUrl' => 'http://localhost:81/admin/login'," /var/www/html/pimcore/app/constants.php
    sudo sed -i "/'healthCheckUrl' =>/c\'healthCheckUrl' => 'http://localhost:81/admin/login'," /var/www/html/pimcore/app/constants.php
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # sudo sed -i '' "s/'80', true]/'81', true]/g" /var/www/html/pimcore/app/constants.php
    # sudo sed -i '' "s/'hostName' => 'localhost'/'hostName' => 'host.docker.internal:81'/g" /var/www/html/pimcore/app/constants.php
    # sudo sed -i '' "s/'ip' => '127.0.0.1'/'ip' => 'host.docker.internal:81'/g" /var/www/html/pimcore/app/constants.php
    sudo cp $myapp_dev_path/pimcore/app/constants.php /var/www/html/pimcore/app/
  fi

fi
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo -E aws s3 cp s3://development-import-export/setup-data/aws_config.ini /opt/code-deploy/config/aws/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        sudo chown -R "$(whoami)" /opt/code-deploy/
        aws s3 cp s3://development-import-export/setup-data/aws_config.ini /opt/code-deploy/config/aws/
    fi

sudo cp $myapp_dev_path/pimcore/var/config/website-settings.php /var/www/html/pimcore/var/config/    
sudo chown -R $pimcore_user:$pimcore_user /var/www/html/pimcore
sudo chmod -R 777 /var/www/html/pimcore
# if [ -f /var/www/html/pimcore/var/config/website-settings.php ]; then
#   tput sgr0
#   sudo -H -u www-data bash -c 'cp $myapp_dev_path/pimcore/var/config/website-settings.php /var/www/html/pimcore/var/config/'
# else
#   sudo -H -u www-data bash -c 'cp $myapp_dev_path/pimcore/var/config/website-settings.php /var/www/html/pimcore/var/config/'
# fi
 
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo rsync -avcq $myapp_dev_path/pimcore/apache2/pimcore.conf /etc/apache2/sites-available/
  sudo rsync -avcq $myapp_dev_path/pimcore/apache2/ports.conf /etc/apache2/
  tput sgr0

  tput setaf 2
  if grep -q ServerName /etc/apache2/apache2.conf; then
    tput setaf 7
    echo "Apache Syntax: "
    tput sgr0
  else
    echo 'ServerName localhost' | sudo tee -a /etc/apache2/apache2.conf >/dev/null
    echo "1. Apache Server Name Added"
  fi
  tput setaf 2
  apachectl configtest | tail -n 1

  sudo service apache2 status | grep running
  sudo a2ensite pimcore.conf
  sudo a2enmod rewrite
  tput sgr0
  sudo service apache2 restart
elif [[ "$OSTYPE" == "darwin"* ]]; then
  sudo rsync -avcq $myapp_dev_path/pimcore/apache2/httpd.conf /usr/local/etc/httpd/
  brew services start httpd
fi

sudo -u $pimcore_user /var/www/html/pimcore/bin/console app:register >/tmp/eureka-heartbeat.log 2>&1 &

if [ $? == "0" ]; then
  tput setaf 2
  echo "Pimcore Registering With Eureka"
  tput sgr0
else
  tput setaf 1
  echo "Pimcore Registraion With Eureka Failed"
  cat /tmp/eureka-heartbeat.log
  tput sgr0
fi
sleep 2

if [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:81/admin/login)" == "200" ]]; then
  tput setaf 2
  tput bold
  echo "Pimcore Default Admin Password: Admin@12345"
  tput sgr0
  tput setaf 3
  echo "Started: browse http://localhost:81/admin"
  tput sgr0
else
  tput setaf 1
  echo "Startup Failed Plz Check..."
fi

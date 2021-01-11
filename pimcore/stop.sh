#/bin/bash

tput setaf 3
tput bold
echo "Stopping Pimcore ...."

  tput setaf 2
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
sudo service apache2 stop
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew services stop httpd
fi

sudo pkill -f app:register
if [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:81/admin/login)" != "200" ]]; then
    tput setaf 3
    echo "Apache Stopped"
else
    tput setaf 1
    echo "Stopped Failed Plz Check..."
fi

 tput sgr0;

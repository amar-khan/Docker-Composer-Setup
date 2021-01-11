#/bin/bash

if [ "$1" == "reinit" ]; then
  tput setaf 1
  read -p "Are you sure you want delete and recreate database [y/n] ? " -n 1 -r
  tput sgr0 echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    tput setaf 3
    echo "Thanks for confirmation we will start in 5 sec ... !"
    sleep 5
    tput sgr0
  else
    tput setaf 3
    tput bold
    echo
    echo "Gracefully exits as you have'nt provided one out of [y/Y]"
    tput sgr0
    exit 1
  fi
fi

if [ "$1" == "dumps" ]; then
  tput setaf 1
  read -p "Are you sure you want drop and import db dumps [y/n] ? " -n 1 -r
  tput sgr0 echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    tput setaf 3
    echo "Thanks for confirmation we will stop nocapp and import dumps in 5 sec ... !"
    sleep 5
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sudo debugport="$debugport" docker-compose -f docker-composer-mac.yml down
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo docker-compose -f docker-composer.yml down
    fi
    tput sgr0
  else
    tput setaf 3
    tput bold
    echo
    echo "Gracefully exits as you have'nt provided one out of [y/Y]"
    tput sgr0
    exit 1
  fi
fi

echo "Setting Up Github Username and Password"
for filename in build_env/*.sh; do
  source $filename
done

export MYSQL_PWD=$SETUP_MYSQL_PWD

if [ "$1" == "init" ]; then
  if [[ -z "$2" ]]; then
    cdir=$(pwd)
    for line in $(cat service.txt); do
      repo="$(echo $line | tr ',' '\n' | head -n1 | xargs)"
      branch="$(echo $line | tr ',' '\n' | tail -n1 | xargs)"
      database=$(echo $repo | xargs | rev | cut -d- -f2 | rev)_db
      tput setaf 4
      echo "Sacning Repo : $repo"
      tput setaf 4
      echo "Branch : $branch"
      tput sgr0
      echo " "
      if [ -d "code/$repo" ]; then
        # Control will enter here if $DIRECTORY exists.
        git --git-dir=code/$repo/.git checkout $branch --quiet
        git --git-dir=code/$repo/.git --work-tree=code/$repo/ pull
      else
        git clone -b $branch https://$git_user:$git_pass@github.com/OitoLabs/$repo.git code/$repo
      fi

      if [ -f "code/$repo/src/main/resources/schema/main.sql" ]; then
        tput setaf 2
        echo "Creating and Intializing database : $database"
        tput sgr0

        cd code/$repo/src/main/resources/schema/

        mysql -u root -h 127.0.0.1 -P 3307 -e "CREATE DATABASE $database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"

        mysql -u root -h 127.0.0.1 -P 3307 $database <main.sql

        if [ "$database" == "buyer_db" ]; then
          echo "org_preferences sedded"
          if [[ "$OSTYPE" == "darwin"* ]]; then
            mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='elasticsearch' where pref_key='es.host';"
          fi
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='scg_es_product' where pref_key='es.product.document'"
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='316e5b48f569f70bac50b9b9915f6c753626371982c327bf1d76502f18735c27' where pref_key='pimcore.apikey'"
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='https://development.test-internal.com/assets-static/assets' where pref_key='staticContentHost'"
        fi
      else
        if [ "$database" == "seller_db" ]; then
          mysql -u root -h 127.0.0.1 -P 3307 -e "CREATE DATABASE $database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"
          tput setaf 2
          echo "Checking Pimcore Dumps Update"
          if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            dumppath="/opt/donotdelete"
          elif [[ "$OSTYPE" == "darwin"* ]]; then
            dumppath="/Users/$(whoami)/donotdelete"
          else
            echo "System Identification: Undefined"
          fi
          tput sgr0
          sudo -E aws s3 sync s3://development-import-export/setup-data/dumps/v2.0/ $dumppath/
          sudo unzip -o $dumppath/seller-dump.zip -d $dumppath/
          echo "Extraction Done"
          echo "Importing Seller Dumps ...."
          sleep 2
          pv $dumppath/seller.sql | mysql -u root -h 127.0.0.1 -P 3307 $database
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "delete from users where name<>'admin'"
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "update users set apikey='2f260b26ea24f56d7ba9608a5d79890ca7d256f40eeeccfd4a31501c7d0a619f' , password='\$2y\$10\$2zJbqFeP.rNiyvthInQDrO0SYXYiuIiZt8yyjU/d7cQPp/cfDbm9e' where name='admin' and admin=1"
        else
          tput setaf 2
          echo "No Database required for $repo"
          tput sgr0
        fi
      fi
      cd $cdir

    done
  else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo sysctl -w vm.max_map_count=262144
      sudo mysql_mem_limit=$mysql_mem_limit docker-compose -f docker-composer.yml up -d mysql
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo mysql_mem_limit=$mysql_mem_limit debugport="$debugport" docker-compose -f docker-composer-mac.yml up -d mysql
    else
      echo "System Identification: Undefined"
    fi
    bash -c 'while [[ "$( mysqladmin ping -h 127.0.0.1 -P 3307 -u root)" != "mysqld is alive" ]]; do sleep 5; x=$(( $x + 1 )) ;tput setaf $x; echo "$x please wait preparing mysql server to healthy ....."  ; done'
    cdir=$(pwd)
    database=$(echo $2 | xargs | rev | cut -d- -f2 | cut -d_ -f2 | rev)_db
    tput sgr0
    tput setaf 2
    if [ -f "code/$2-service/src/main/resources/schema/main.sql" ]; then
      echo "Creating and Intializing database : $database"
      tput sgr0
      if [ -d "code/$2-service" ]; then
        # Control will enter here if $DIRECTORY exists.
        git --git-dir=code/$2-service/.git --work-tree=code/$2-service/ pull
      else
        git clone --depth 1 -b development https://$git_user:$git_pass@github.com/OitoLabs/$2-service.git code/$2-service
      fi
      cd code/$2-service/src/main/resources/schema/

      mysql -u root -h 127.0.0.1 -P 3307 -e "CREATE DATABASE $database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"

      mysql -u root -h 127.0.0.1 -P 3307 $database <main.sql

      if [ "$database" == "buyer_db" ]; then

        echo "org_preferences sedded"

        if [[ "$OSTYPE" == "darwin"* ]]; then
          mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='elasticsearch' where pref_key='es.host';"
        fi

        mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='scg_es_product' where pref_key='es.product.document'"
        mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='316e5b48f569f70bac50b9b9915f6c753626371982c327bf1d76502f18735c27' where pref_key='pimcore.apikey'"
        mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='https://development.test-internal.com/assets-static/assets' where pref_key='staticContentHost'"
        mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value='false' where pref_key='signupOtpEnabled'"
      fi
    else
      if [ "$database" == "seller_db" ]; then
        mysql -u root -h 127.0.0.1 -P 3307 -e "CREATE DATABASE $database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"
        tput setaf 2
        echo "Checking Pimcore Dumps Update"
        tput sgr0

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
          dumppath="/opt/donotdelete"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
          dumppath="/Users/$(whoami)/donotdelete"
        else
          echo "System Identification: Undefined"
        fi
        sudo -E aws s3 sync s3://development-import-export/setup-data/dumps/v2.0/ $dumppath/
        sudo unzip -o $dumppath/seller-dump.zip -d $dumppath/
        echo "Extraction Done"
        echo "Importing Seller Dumps ...."
        sleep 2
        pv $dumppath/seller.sql | mysql -u root -h 127.0.0.1 -P 3307 $database
        mysql -u root -h 127.0.0.1 -P 3307 $database -e "delete from users where name<>'admin'"
        mysql -u root -h 127.0.0.1 -P 3307 $database -e "update users set apikey='2f260b26ea24f56d7ba9608a5d79890ca7d256f40eeeccfd4a31501c7d0a619f' , password='\$2y\$10\$2zJbqFeP.rNiyvthInQDrO0SYXYiuIiZt8yyjU/d7cQPp/cfDbm9e' where name='admin' and admin=1"
      else
        tput setaf 2
        echo "No Database required for $2"
        tput sgr0
      fi
    fi
    cd $cdir
  fi
fi

if [ "$1" == "drop" ]; then
  if [[ -z "$2" ]]; then

    while IFS= read -r line; do
      repo="$(echo $line | tr ',' '\n' | head -n1 | xargs)"
      branch="$(echo $line | tr ',' '\n' | tail -n1 | xargs)"
      database=$(echo $repo | xargs | rev | cut -d- -f2 | rev)_db
      if [ -f "code/$repo/src/main/resources/schema/main.sql" ]; then
        tput setaf 1
        echo "Destroying database : $database"
        tput sgr0
        mysql -u root -Ns -h 127.0.0.1 -P 3307 -e "drop database $database"
        sleep 1
      fi
    done <service.txt

  else
    database=$(echo $2 | xargs | rev | cut -d- -f2 | cut -d_ -f2 | rev)_db
    tput setaf 1
    echo "Destroying database : $database"
    tput sgr0
    mysql -u root -Ns -h 127.0.0.1 -P 3307 -e "drop database $database"
  fi
  cd $cdir
fi

if [ "$1" == "reinit" ]; then
  if [[ -z "$2" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo sysctl -w vm.max_map_count=262144
      sudo mysql_mem_limit=2048m docker-compose -f docker-composer.yml up -d mysql
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo mysql_mem_limit=2048m debugport="$debugport" docker-compose -f docker-composer-mac.yml up -d mysql
    else
      echo "System Identification: Undefined"
    fi
  else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo sysctl -w vm.max_map_count=262144
      sudo mysql_mem_limit=$mysql_mem_limit docker-compose -f docker-composer.yml up --detach --no-deps --build mysql
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo mysql_mem_limit=$mysql_mem_limit debugport="$debugport" docker-compose -f docker-composer-mac.yml up --detach --no-deps --build mysql
    else
      echo "System Identification: Undefined"
    fi

  fi
  bash -c 'while [[ "$( mysqladmin ping -h 127.0.0.1 -P 3307 -u root)" != "mysqld is alive" ]]; do sleep 5; x=$(( $x + 1 )) ;tput setaf $x; echo "$x please wait preparing mysql server to healthy ....."  ; done'

  /bin/bash database.sh drop "$2"
  /bin/bash database.sh init "$2"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo sysctl -w vm.max_map_count=262144
    sudo mysql_mem_limit=$mysql_mem_limit docker-compose -f docker-composer.yml up --force-recreate --detach --no-deps --build mysql
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    sudo mysql_mem_limit=$mysql_mem_limit debugport="$debugport" docker-compose -f docker-composer-mac.yml up --force-recreate --detach --no-deps --build mysql
  else
    echo "System Identification: Undefined"
  fi

fi

if [ "$1" == "dumps" ]; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    dumppath="/opt/donotdelete"
    composerfile="docker-composer.yml"
    sudo mysql_mem_limit=2048m docker-compose -f docker-composer.yml up -d mysql
    database=$(echo $2 | xargs | rev | cut -d- -f2 | cut -d_ -f2 | rev)_db
    sudo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/dumps/$database.sql $dumppath/
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    dumppath="/Users/$(whoami)/donotdelete"
    composerfile="docker-composer-mac.yml"
    sudo mysql_mem_limit=2048m debugport="$debugport" docker-compose -f docker-composer-mac.yml up -d mysql
    database=$(echo $2 | xargs | rev | cut -d- -f2 | cut -d_ -f2 | rev)_db
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/dumps/$database.sql $dumppath/
  else
    echo "System Identification: Undefined"
  fi
  bash -c 'while [[ "$( mysqladmin ping -h 127.0.0.1 -P 3307 -u root)" != "mysqld is alive" ]]; do sleep 5; x=$(( $x + 1 )) ;tput setaf $x; echo "$x please wait preparing mysql server to healthy ....."  ; done'
  mysql -u root -Ns -h 127.0.0.1 -P 3307 -e "drop database $database"
  mysql -u root -h 127.0.0.1 -P 3307 -e "CREATE DATABASE $database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci"
  echo "aws s3 ls s3://development-import-export/setup-data/dumps/$database.sql --recursive --human-readable --summarize | grep Size | grep -Eo '[0-9]{1,4}' | head -n1"
  dumpSize=$(aws s3 ls s3://development-import-export/setup-data/dumps/$database.sql --recursive --human-readable --summarize | grep Size | grep -Eo '[0-9]{1,4}' | head -n1)
  tput setaf 2
  pv --size "${dumpSize}m" $dumppath/$database.sql | mysql -u root -h 127.0.0.1 -P 3307 $database
  tput sgr0
  if [ "$database" == "seller_db" ]; then
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "delete from users where name<>'admin'"
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "update users set apikey='2f260b26ea24f56d7ba9608a5d79890ca7d256f40eeeccfd4a31501c7d0a619f' , password='\$2y\$10\$2zJbqFeP.rNiyvthInQDrO0SYXYiuIiZt8yyjU/d7cQPp/cfDbm9e' where name='admin' and admin=1"
  fi
  if [ "$database" == "buyer_db" ]; then
    echo "org_preferences sedded"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='elasticsearch' where pref_key='es.host';"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='localhost' where pref_key='es.host';"
    fi
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='9200' where pref_key='es.port';"
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='scg_es_product' where pref_key='es.product.document'"
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='316e5b48f569f70bac50b9b9915f6c753626371982c327bf1d76502f18735c27' where pref_key='pimcore.apikey'"
    mysql -u root -h 127.0.0.1 -P 3307 $database -e "update org_preferences set pref_value ='https://development.test-internal.com/assets-static/assets' where pref_key='staticContentHost'"
  fi
  sudo mysql_mem_limit=$mysql_mem_limit debugport="$debugport" docker-compose -f $composerfile up --force-recreate --detach --no-deps --build mysql
fi

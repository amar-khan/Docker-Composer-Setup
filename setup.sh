#/bin/bash

if [ "$1" == "server" ]; then
  tput setaf 15
  tput bold
  echo "###############################"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "System Identification: Ubuntu"
    jdkName="jdk-11.0.7_linux-x64_bin.tar.gz"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "System Identification: MAC-OS"
    jdkName="jdk-11.0.8_osx-x64_bin.tar.gz"
  else
    echo "System Identification: Undefined"
  fi
  echo "###############################"
  tput sgr0
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    if ! command -v curl &>/dev/null; then
      tput setaf 3
      echo "Installing curl client...."
      sudo apt install -y curl
      tput sgr0
    else
      tput setaf 14
      echo "curl already client installed"
      tput sgr0
    fi
    if ! command -v ansible &>/dev/null; then
      tput setaf 3
      echo "Installing ansible client...."
      sudo apt-add-repository ppa:ansible/ansible -y
      sudo apt install -y ansible
      tput sgr0
    else
      tput setaf 14
      echo "ansible-vault already client installed"
      tput sgr0
    fi
    if ! command -v docker &>/dev/null; then
      tput setaf 3
      echo "Installing docker client...."
      tput sgr0
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sleep 1
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt-get update
      sudo apt-get install -y docker-ce
      tput setaf 3
      echo "Docker Clinet Installed"
      tput sgr0
      sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      docker-compose --version
      tput setaf 3
      echo "Docker Composer Installed"
      tput sgr0
    else
      tput setaf 14
      echo "docker already client installed"
      tput sgr0
    fi
    if ! command -v mysql &>/dev/null; then
      tput setaf 3
      echo "Installing mysql client...."
      sudo apt install -y mysql-client-5.7
      tput sgr0
    else
      tput setaf 14
      echo "mysql already client installed"
      tput sgr0
    fi

    if ! command -v jq &>/dev/null; then
      tput setaf 3
      echo "Installing jq client...."
      sudo apt-get install -y jq
      tput sgr0
    else
      tput setaf 14
      echo "jq already installed"
      tput sgr0
    fi
    if ! command -v unzip &>/dev/null; then
      tput setaf 3
      echo "Installing unzip client...."
      sudo apt install -y unzip
      tput sgr0
    else
      tput setaf 14
      echo "unzip already installed"
      tput sgr0
    fi
    if ! command -v pv &>/dev/null; then
      tput setaf 3
      echo "Installing pv client...."
      sudo apt install -y pv
      tput sgr0
    else
      tput setaf 14
      echo "pv already installed"
      tput sgr0
    fi

    if aws --version | grep -q '/2.'; then
      tput setaf 14
      echo "aws already installed"
      tput sgr0
    else
      tput setaf 3
      echo "Installing aws client...."
      tput sgr0
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      echo "Extracting awscliv2 ..."
      unzip -q -o awscliv2.zip
      sudo ./aws/install
      rm -rf awscliv2.zip
    fi
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if ! command -v wget &>/dev/null; then
      tput setaf 3
      echo "Installing wget client...."
      tput sgr0
      brew install wget
    else
      tput setaf 14
      echo "wget already installed"
      tput sgr0
    fi
    if ! command -v ansible &>/dev/null; then
      tput setaf 3
      echo "Installing ansible client...."
      tput sgr0
      brew install ansible
    else
      tput setaf 14
      echo "ansible already installed"
      tput sgr0
    fi
    if ! command -v jq &>/dev/null; then
      tput setaf 3
      echo "Installing jq client...."
      tput sgr0
      brew install jq
    else
      tput setaf 14
      echo "jq already installed"
      tput sgr0
    fi

    if ! command -v pv &>/dev/null; then
      tput setaf 3
      echo "Installing pv client...."
      tput sgr0
      brew install pv
    else
      tput setaf 14
      echo "pv already installed"
      tput sgr0
    fi
    if ! command -v mysql &>/dev/null; then
      tput setaf 3
      echo "Installing mysql client...."
      tput sgr0
      brew install mysql
    else
      tput setaf 14
      echo "mysql client already installed"
      tput sgr0
    fi

    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg ./AWSCLIV2.pkg -target /
    rm -rf ./AWSCLIV2.pkg
    aws --version

  fi
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    javadir="/opt/donotdelete"
    sudo mkdir -p $javadir/jdk-11

  elif [[ "$OSTYPE" == "darwin"* ]]; then
    javadir="/Users/$(whoami)/donotdelete"
    mkdir -p $javadir/jdk-11
  else
    echo "System Identification: Undefined"
  fi

  if [ -f $javadir/$jdkName ]; then
    sudo tar -C $javadir/jdk-11 -xf $javadir/$jdkName --strip-components 1
    sudo tar -C $javadir/ -xf $javadir/$jdkName
  else
    sudo wget -P $javadir/ https://tmp-myapp-bucket.s3-ap-southeast-1.amazonaws.com/$jdkName
    sudo tar -C $javadir/jdk-11 -xf $javadir/$jdkName --strip-components 1
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export JAVA_HOME="$javadir/jdk-11"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    export JAVA_HOME=$javadir/jdk-11/jdk-11.0.8.jdk/Contents/Home/
  else
    echo "System Identification: Undefined"
  fi

  export PATH="$JAVA_HOME/bin":"$PATH"

  java --version

  curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

  source ~/.profile
  source $HOME/.nvm/nvm.sh
  nvm --version

  # Instaling Node 10
  nvm install v10.7.0
  npm --version
  node -v
   if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v docker &>/dev/null; then
    tput setaf 3
    echo "Installing docker client...."
    tput sgr0
    wget -P ~/donotdelete/ https://development-import-export.s3-ap-southeast-1.amazonaws.com/setup-data/Docker.dmg
    sleep 2
    open ~/donotdelete/Docker.dmg
  else
    tput setaf 14
    echo "docker already installed"
    tput sgr0
  fi
  fi
fi

if [ "$1" == "es" ]; then
  if [ "$2" == "raw" ]; then
    tput setaf 3
    echo "Downloading Transformed data for es import ... !"
    tput sgr0
    sleep 2
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo es_mem_limit=$es_mem_limit docker-compose -f docker-composer.yml rm --stop -f elasticsearch
      esdir="/opt/donotdelete"
      sudo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/estransdata.zip $esdir/
      echo "Extracting...."
      sudo rm -rf $esdir/tmp/
      sudo unzip -q -o $esdir/estransdata.zip -d $esdir/
      sudo rm -rf $esdir/estransdata.zip
      composerfile="docker-composer.yml"
      sudo rm -rf $esdir/esdata
      sudo mv $esdir/tmp/esdata/ $esdir/esdata/
      sudo chmod 755 $esdir/esdata/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo es_mem_limit=$es_mem_limit debugport="$debugport" docker-compose -f docker-composer-mac.yml rm --stop -f elasticsearch
      esdir="/Users/$(whoami)/donotdelete"
      composerfile="docker-composer-mac.yml"
      AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/estransdata.zip $esdir/
      echo "Extracting...."
      rm -rf $esdir/tmp/
      unzip -q -o $esdir/estransdata.zip -d $esdir/
      rm -rf $esdir/estransdata.zip
      rm -rf $esdir/esdata
      mv $esdir/tmp/esdata/ $esdir/esdata/
      chmod 755 $esdir/esdata/
    else
      echo "System Identification: Undefined"
    fi
    tput setaf 2
    echo "## Es Dumps Imported Successfully ... !"
    tput sgr0
    sudo es_mem_limit=$es_mem_limit debugport="$debugport" docker-compose -f $composerfile up --force-recreate --detach --no-deps --build elasticsearch
  else
    tput setaf 2
    echo "Nocapp all services will be down during es import ... !"
    sleep 5
    sudo debugport="$debugport" docker-compose -f docker-composer.yml down
    tput sgr0
    for filename in build_env/*.sh; do
      echo "Sourcing : $filename"
      source $filename
    done
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      esdir="/opt/donotdelete"
      sudo AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/es-data.zip $esdir/
      sudo unzip -o $esdir/es-data.zip -d $esdir/es-data/
      sudo rm -rf $esdir/es-data.zip

    elif [[ "$OSTYPE" == "darwin"* ]]; then
      esdir="/Users/$(whoami)/donotdelete"
      AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp s3://development-import-export/setup-data/es-data.zip $esdir/
      unzip -q -o $esdir/es-data.zip -d $esdir/es-data/
      rm -rf $esdir/es-data.zip
    else
      echo "System Identification: Undefined"
    fi

    source ~/.profile
    source $HOME/.nvm/nvm.sh
    nvm --version
    # Using Node 10
    nvm use v10.7.0
    npm --version
    node -v
    npm install -g elasticdump

    sleep 2
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo sysctl -w vm.max_map_count=262144
      sudo es_mem_limit=2048m docker-compose -f docker-composer.yml up --force-recreate --detach --no-deps --build elasticsearch
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo debugport="$debugport" es_mem_limit=2048m docker-compose -f docker-composer-mac.yml up --force-recreate --detach --no-deps --build elasticsearch
    else
      echo "System Identification: Undefined"
    fi

    bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9200)" != "200" ]] ;do sleep 5 ; echo "waiting for es server to come up ....."; done'

    curl -X DELETE http://localhost:9200/scg_es_product_th
    curl -X DELETE http://localhost:9200/scg_es_product_en
    curl -X DELETE http://localhost:9200/address_en
    curl -X DELETE http://localhost:9200/address_th

    curl -X PUT \
      http://localhost:9200/scg_es_product_th \
      -H 'Content-Type: application/json' \
      -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
      -H 'cache-control: no-cache' \
      -d '{
            "index.mapping.total_fields.limit": 2000
          }'

    curl -X PUT \
      http://localhost:9200/scg_es_product_en \
      -H 'Content-Type: application/json' \
      -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
      -H 'cache-control: no-cache' \
      -d '{
            "index.mapping.total_fields.limit": 2000
          }'
    curl -X PUT \
      http://localhost:9200/address_en \
      -H 'Content-Type: application/json' \
      -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
      -H 'cache-control: no-cache' \
      -d '{
            "index.mapping.total_fields.limit": 2000
          }'

    curl -X PUT \
      http://localhost:9200/address_th \
      -H 'Content-Type: application/json' \
      -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
      -H 'cache-control: no-cache' \
      -d '{
            "index.mapping.total_fields.limit": 2000
          }'

    # Import ES Dumps
    ####################################################################################################################################
    # MAPPING PUSH TO ES
    elasticdump --input=$esdir/es-data/address_en_mapping.json --output=http://localhost:9200/address_en --type=mapping
    sleep 2
    elasticdump --input=$esdir/es-data/address_th_mapping.json --output=http://localhost:9200/address_th --type=mapping
    sleep 2
    tput setaf 14
    echo "address_en data import in process ...."
    elasticdump --quiet --input=$esdir/es-data/address_en_data.json --output=http://localhost:9200/address_en --type=data
    sleep 2
    echo "address_th data import in process ...."
    elasticdump --quiet --input=$esdir/es-data/address_th_data.json --output=http://localhost:9200/address_th --type=data

    echo ""
    tput sgr0
    # DATA PUSH TO ES
    sleep 2
    elasticdump --input=$esdir/es-data/scg_es_product_en_mapping.json --output=http://localhost:9200/scg_es_product_en --type=mapping
    sleep 2
    elasticdump --input=$esdir/es-data/scg_es_product_th_mapping.json --output=http://localhost:9200/scg_es_product_th --type=mapping
    sleep 2
    tput setaf 14
    echo "scg_es_product_en data import in process ...."
    elasticdump --quiet --input=$esdir/es-data/scg_es_product_en_data.json --output=http://localhost:9200/scg_es_product_en --type=data
    sleep 2
    echo "scg_es_product_th data import in process ...."
    elasticdump --quiet --input=$esdir/es-data/scg_es_product_th_data.json --output=http://localhost:9200/scg_es_product_th --type=data
    echo ""
    tput sgr0

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo sysctl -w vm.max_map_count=262144
      sudo es_mem_limit="" docker-compose -f docker-composer.yml rm --stop -f elasticsearch
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      sudo es_mem_limit="" debugport="$debugport" docker-compose -f docker-composer-mac.yml rm --stop -f elasticsearch
    else
      echo "System Identification: Undefined"
    fi
  fi
fi

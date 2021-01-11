# download library

for filename in build_env/*.sh; do
    echo "Sourcing : $filename"
    source $filename
done

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    pimcore_user="www-data"
    dnotddir="/opt/donotdelete"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    pimcore_user="_www"
    dnotddir="/Users/$(whoami)/donotdelete"
fi

if [ -f "$dnotddir/pimcore-baseline.zip" ]; then
    tput setaf 2
    echo "Extracting Files...."
    tput sgr0
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo unzip -q -o $dnotddir/pimcore-baseline.zip -d $dnotddir/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        unzip -q -o $dnotddir/pimcore-baseline.zip -d $dnotddir/
    fi
else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo -E aws s3 cp s3://development-import-export/setup-data/pimcore-baseline.zip $dnotddir/
        sudo unzip -q -o $dnotddir/pimcore-baseline.zip -d $dnotddir/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        aws s3 cp s3://development-import-export/setup-data/pimcore-baseline.zip $dnotddir/
        unzip -q -o $dnotddir/pimcore-baseline.zip -d $dnotddir/
    fi
    tput setaf 2
    echo "Extracting Files...."
    tput sgr0
fi

if [ -d /var/www/html/pimcore ]; then
    echo "Already Installation Directory Found..."
    tput setaf 1
    echo " "
    read -p "Are you sure you want to rename exiting /var/www/html/pimcore to /var/www/html/pimcore-$(date +%y-%m-%d-%s) [y/n] ? " -n 1 -r
    echo
    sleep 5
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if sudo mv /var/www/html/pimcore /var/www/html/pimcore-$(date +%y-%m-%d-%s); then
            tput sgr0
            sudo mkdir -m 777 -p /var/www/html/pimcore
            echo "Moved Exiting Directory Of Pimcore Successfully"
        else
            tput setaf 1
            echo "Moving Exiting Directory Of Pimcore Encountered Issues."
            tput sgr0
            echo
        fi
    else
        echo
        tput setaf 3
        tput bold
        echo "Gracefully exits as you have'nt provided one out of [y/Y]"
        exit 1
        tput sgr0
    fi
else
    echo "Installation Directory Found Clean ..."
    sudo mkdir -m 777 -p /var/www/html/pimcore
fi

if sudo mv $dnotddir/pimcore/* /var/www/html/pimcore/; then
    tput setaf 3
    tput bold
    echo "Installation Content Deployed To /var/www/html/pimcore/ ..."
    echo
    echo "Setting Pimcore Directory Permission"
    sudo chown -R $pimcore_user:$pimcore_user /var/www/html/
    sudo chmod -R 777 /var/www/html/
    tput sgr0
    echo
else
    tput setaf 1
    echo "Failed To Move Installation Conetent To /var/www/html/pimcore/ ..."
    tput sgr0
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt update
    sudo apt-get install -y php-pear php7.2-dev php7.2-bz2 composer nfs-common wget zip unzip apache2 php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-intl php7.2-mysql php7.2-xml php7.2-zip php-redis php-apcu ffmpeg ghostscript php-imagick
    sudo a2enmod php7.2
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install php@7.3
    brew install php@7.2
    brew link php@7.2
    brew install composer
    wget https://getcomposer.org/download/1.8.6/composer.phar -P /tmp/
    chmod +x /tmp/composer.phar
    sudo mv /tmp/composer.phar /usr/local/bin/composer
    which php 
    echo 'export PATH="/usr/local/opt/php@7.2/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="/usr/local/opt/php@7.2/sbin:$PATH"' >> ~/.zshrc
    echo 'export PATH="/usr/local/opt/php@7.2/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="/usr/local/opt/php@7.2/sbin:$PATH"' >> ~/.bashrc    
    source ~/.zshrc
    source ~/.bashrc
    which php
    brew  apacheCtl stop
    brew install httpd
    pecl install php-pear php7.2-dev php7.2-bz2 composer nfs-common wget zip unzip php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-intl php7.2-mysql php7.2-xml php7.2-zip php-redis php-apcu ffmpeg ghostscript php-imagick
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo sed -i 's,^post_max_size =.*$,post_max_size = 160M,' /etc/php/7.2/apache2/php.ini
    sudo sed -i 's,^upload_max_filesize =.*$,upload_max_filesize = 160M,' /etc/php/7.2/apache2/php.ini
    sudo sed -i 's,^max_file_uploads =.*$,max_file_uploads = 50,' /etc/php/7.2/apache2/php.ini
    sudo sed -i 's,^session.cookie_path =.*$,session.cookie_path = /,' /etc/php/7.2/apache2/php.ini
elif [[ "$OSTYPE" == "darwin"* ]]; then
    sudo sed -i '' 's,^post_max_size =.*$,post_max_size = 160M,' /usr/local/etc/php/7.2/php.ini
    sudo sed -i '' 's,^upload_max_filesize =.*$,upload_max_filesize = 160M,' /usr/local/etc/php/7.2/php.ini
    sudo sed -i '' 's,^max_file_uploads =.*$,max_file_uploads = 50,' /usr/local/etc/php/7.2/php.ini
    sudo sed -i '' 's,^session.cookie_path =.*$,session.cookie_path = /,' /usr/local/etc/php/7.2/php.ini
fi

sudo mkdir -p /opt/code-deploy/config/aws/
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo -E aws s3 cp s3://development-import-export/setup-data/aws_config.ini /opt/code-deploy/config/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        aws s3 cp s3://development-import-export/setup-data/aws_config.ini /opt/code-deploy/config/
    fi
sudo chown -R $pimcore_user:$pimcore_user /opt/code-deploy/config/
# sudo rsync -avcq $myapp_dev_path/pimcore/aws_config.ini /opt/code-deploy/config/aws/

sudo rsync -rt --keep-dirlinks --rsync-path="sudo -u $pimcore_user rsync" --links --progress --chown=$pimcore_user:$pimcore_user --chmod=777 --exclude config -r code/seller-service/* /var/www/html/pimcore/

sudo chown -R $pimcore_user:$pimcore_user /var/www/html/pimcore
sudo chmod -R 777 /var/www/html/pimcore

sudo -H -u $pimcore_user bash -c 'composer update -d /var/www/html/pimcore/'

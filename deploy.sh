#/bin/bash

ser_count=`cat service.txt | wc -l`
x=0;

btachCount=$((100 / ser_count))

export workingDir=`pwd`
for d in $(cat service.txt); do
d="`echo $d | tr ',' '\n' | head -n1 | xargs`";
tput setaf 11 ;echo -ne "Syncing Artifacts ...  (%$x)\r"
x=$((x + btachCount))
tput sgr0
# x=$(( $x + 1 )); echo "$x Service initilization : $d"
    if [ -d "code/$d" ]; then
        if [[ "$d" =~ "ui" ]] ;then
            if [ -d "code/$d/dist" ]; then
            if [ "$(ls -A code/$d/dist)" ]; then
                mkdir -p $workingDir/artifact/$d/
                rsync -a -r -avcq $workingDir/code/$d/dist $workingDir/artifact/$d/
                rsync -avcq  $workingDir/docker/DevDockerNodefile $workingDir/artifact/$d/dist/
                rsync -avcq  $workingDir/code/$d/config/dev/.htaccess $workingDir/artifact/$d/dist/
                rsync -avcq  $workingDir/code/$d/config/dev/*.conf $workingDir/artifact/$d/dist/
                rsync -avcq  $workingDir/config/apache2/httpd.conf $workingDir/artifact/$d/dist/
                if [[ $d == *"buyer-ui"* ]]; then
                jq '.env="development" | .apis.buyer.baseurl="https://development.test-internal.com/buyer-service" | .apis.buyer.baService="https://development.test-internal.com/buyer-intraction" | .apis.apigateway.baseurl="https://development.test-internal.com/api-gateway-service" | .apis.order.baseurl="https://development.test-internal.com/order-service" | .apis.auth.baseurl="https://development.test-internal.com/authentication-service" | .apis.logistics.baseurl="https://development.test-internal.com/logistics-service" | .apis.installation.baseurl="https://development.test-internal.com/installer-service" | .apis.staticContent.baseurl="https://development.test-internal.com"| .apis.promotion.baseurl="https://development.test-internal.com/promotion-service" | .apis.cache.baseurl="https://development.test-internal.com/cache-service"' $workingDir/artifact/$d/dist/config/appconfig.json > $workingDir/artifact/$d/dist/config/appconfig-dev.json
                fi
                if [[ $d == *"seller-ui"* ]]; then
                jq '.sellerBase.baseurl="https://development.test-internal.com/seller" | .apigateway.baseurl="https://development.test-internal.com/api-gateway-service" | .baservice.baseurl="https://development.test-internal.com/buyer-intraction" | .buyer.baseurl="https://development.test-internal.com/seller/buyer-service" | .apis.baseurl="https://development.test-internal.com/seller/seller-service" | .analyticsapis.baseurl="https://development.test-internal.com/seller/wh-data-service" | .installation.baseurl="https://development.test-internal.com/seller/installer-service" | .auth.baseurl="https://development.test-internal.com/seller/authentication-service" | .promotionapis.baseurl="https://development.test-internal.com/seller/promotion-service"  | .importserviceapis.baseurl="https://development.test-internal.com/seller/import-service" | .logisticsapis.baseurl="https://development.test-internal.com/seller/logistics-service" | .cache.baseurl="https://development.test-internal.com/seller/cache-service" | .orderserviceapis.baseurl="https://development.test-internal.com/seller/order-service/seller-orders"' $workingDir/artifact/$d/dist/config/appconfig.json > $workingDir/artifact/$d/dist/config/appconfig-dev.json
                fi
                mv $workingDir/artifact/$d/dist/config/appconfig-dev.json  $workingDir/artifact/$d/dist/config/appconfig.json
                [ -f $workingDir/artifact/$d/dist/index-qa.html ] && mv $workingDir/artifact/$d/dist/index-qa.html  $workingDir/artifact/$d/dist/index.html
                cd $workingDir
            fi
            fi
        fi
        if [[ $d == *"-service"* ]]; then
            if ls code/$d/build/libs/*.jar 1> /dev/null 2>&1 ; then
                mkdir -p $workingDir/artifact/$d/
                rsync -avcq --progress $workingDir/code/$d/build/libs/*.jar $workingDir/artifact/$d/
                rsync -avcq  $workingDir/docker/DevDockerfile $workingDir/artifact/$d/
                if [[ $d == *"order-service"* ]]; then
                rsync -avcq  $workingDir/config/order/oito_private.pem $workingDir/artifact/$d/
                fi
                cd $workingDir
            fi
        fi
fi
done

tput setaf 11 ;echo -ne "Syncing Artifacts ...  (%100)\r"
tput sgr0
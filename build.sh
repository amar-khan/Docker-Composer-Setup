#/bin/bash

tput setaf 5
echo "********* Setting Up Java Path $d **********"
tput setaf 2
echo "Done"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export JAVA_HOME="/opt/donotdelete/jdk-11"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export JAVA_HOME="/Users/$(whoami)/donotdelete/jdk-11/jdk-11.0.8.jdk/Contents/Home/"
else
    echo "System Identification: Undefined"
fi
export PATH="$JAVA_HOME/bin":"$PATH"

export workingDir=$(pwd)

if [[ -z "$1" ]]; then
    tput setaf 3
    echo "********* ServiceName: ALL Building **********"
    echo ""

    # while IFS= read -r d; do
    for d in $(cat service.txt); do
        d="$(echo $d | tr ',' '\n' | head -n1 | xargs)"
        if [[ "$d " =~ "ui" ]]; then
            tput setaf 7
            echo "*****************************************************"
            tput setaf 7
            echo -ne "*********" && tput setaf 3 && echo -ne " Now Budiling $d " && tput setaf 7 && echo "**********"
            tput setaf 7
            echo "******************************************************"
            cd code/$d
            source ~/.profile
            source $HOME/.nvm/nvm.sh
            npm install
            sleep 1
            if [ -f package.json ]; then
                if grep -q 'build-all' "package.json"; then
                    npm run build-all
                else
                    npm run build
                fi
            fi
        else
            if [[ $d == *"-store"* ]]; then
                echo "************ No Build Required For $d **************"
            elif [[ $d == *"seller-service"* ]]; then
                echo "************ No Build Required For $d **************"
            else
                cd code/$d
                tput setaf 7
                echo "*****************************************************"
                tput setaf 7
                echo -ne "*********" && tput setaf 3 && echo -ne " Now Budiling $d " && tput setaf 7 && echo "**********"
                tput setaf 7
                echo "******************************************************"
                ./gradlew clean build -x Test -Partifactory_password=$artifactory_password
                sleep 1
            fi
        fi
        cd $workingDir
    done
else
    if [[ "$1 " =~ "ui" ]]; then
        tput setaf 7
        echo "*****************************************************"
        tput setaf 7
        echo -ne "*********" && tput setaf 3 && echo -ne " Now Budiling $1 " && tput setaf 7 && echo "**********"
        tput setaf 7
        echo "******************************************************"
        cd code/$1
        source ~/.profile
        source $HOME/.nvm/nvm.sh
        npm install
        sleep 1
        if [ -f package.json ]; then
            if grep -q 'build-all' "package.json"; then
                npm run build-all
            else
                npm run build
            fi
        fi
    else
        if [[ $1 == *"-store"* ]]; then
            tput setaf 7
            echo "************ No Build Required For $1 **************"
        elif [[ $1 == *"seller-service"* ]]; then
            tput setaf 7
            echo "************ No Build Required For $1 **************"
        else
            tput setaf 7
            echo "*****************************************************"
            tput setaf 7
            echo -ne "*********" && tput setaf 3 && echo -ne " Now Budiling $1 " && tput setaf 7 && echo "**********"
            tput setaf 7
            echo "******************************************************"
            cd code/$1
            ./gradlew clean build -x Test  -Partifactory_password=$artifactory_password
        fi
    fi
    cd $workingDir
fi

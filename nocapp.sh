#/bin/bash

function nocapp() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        composefile="docker-composer.yml"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        composefile="docker-composer-mac.yml"
    else
        echo "System Identification: Undefined"
    fi

    ncdir=$(pwd)

    cd $myapp_dev_path
    CMD="$1_$2"

    if [[ "$(echo "$3" | tr '[:upper:]' '[:lower:]')" =~ "pimcore" ]]; then

        CMD="$1_$2_$(echo "$3" | tr '[:upper:]' '[:lower:]')"
    fi

    /bin/bash ./info.sh

    tput setaf 7
    tput sgr0
    echo " "

    if [[ "$2" =~ "status" || "$2" =~ "start" || "$2" =~ "restart" || "$2" =~ "rebuild" ]]; then
        dbupdates=""
        if MYSQL_PWD=root mysqladmin -s ping -h 127.0.0.1 -P 3307 -u root | grep -q alive; then
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                dbupdates=$(./dbsync.sh dry | grep "Database:" | awk '{print $3}' | xargs -n1 | sort -u | xargs)
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                dbupdates=$(./dbsync.sh dry | grep "Database:" | awk '{print $3}' | xargs -n1 | sort -u | xargs)
            else
                echo "System Identification: Undefined"
            fi

        fi
        if [ -z "$dbupdates" ]; then
            true
        else
            tput setaf 6
            echo "☎  DB Updates: $dbupdates"
            echo ""
            tput sgr0
        fi

    fi

    if [[ "$3" =~ "mode" ]]; then
        param=$(echo $(cat $myapp_dev_path/modes/$3) | tr '\n' ' ')
        tput setaf 6
        echo "Activated Mode: $3" | tr '[:lower:]' '[:upper:]'
    else
        param="$3"
    fi
    tput sgr0

    for filename in build_env/*.sh; do
        # echo "Sourcing : $filename"
        source $filename
    done

    case "${CMD}" in
    dev_status)
        sudo -Eu root bash -c "docker-compose -f $composefile ps $param"
        cd $ncdir
        ;;
    dev_top)
        sudo -Eu root bash -c "docker-compose -f $composefile top $param"
        cd $ncdir
        ;;
    dev_uptime)
        sudo -Eu root bash -c "docker ps -f status=running -f name=$param --format '{{.Names}}\t\t\t{{.Status}}'"
        cd $ncdir
        ;;
    dev_pause)
        sudo -Eu root bash -c "docker-compose -f $composefile pause $param"
        cd $ncdir
        ;;
    dev_unpause)
        sudo -Eu root bash -c "docker-compose -f $composefile unpause $param"
        cd $ncdir
        ;;
    dev_kill)
        sudo -Eu root bash -c "docker-compose -f $composefile kill $param"
        cd $ncdir
        ;;
    dev_events)
        sudo -Eu root bash -c "docker-compose -f $composefile events $param"
        cd $ncdir
        ;;
    dev_resource)
        sudo -Eu root bash -c "docker stats"
        cd $ncdir
        ;;
    dev_variable)
        sudo docker inspect $3 | jq '.[0].Config.Env'
        cd $ncdir
        ;;
    dev_start)
        /bin/bash ./deploy.sh
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [ $(cat /proc/sys/vm/max_map_count) != "262144" ]; then sudo sysctl -w vm.max_map_count=262144; fi
        fi
        if [[ "$4" =~ "debug" ]]; then
            echo "Debug Port: $5"
            sudo -Eu root bash -c "sudo debugport="$5:$5" JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address="0.0.0.0:$5" docker-compose -f $composefile up --no-deps  -d $param"
        else
            sudo -Eu root bash -c "docker-compose -f $composefile up -d $param"
        fi
        cd $ncdir
        ;;
    dev_start_pimcore)
        /bin/bash ./pimcore/start.sh
        cd $ncdir
        ;;
    dev_stop_pimcore)
        /bin/bash ./pimcore/stop.sh
        cd $ncdir
        ;;
    dev_restart_pimcore)
        /bin/bash ./pimcore/stop.sh
        /bin/bash ./pimcore/start.sh
        cd $ncdir
        ;;
    dev_stop)
        sudo -Eu root bash -c "docker-compose -f $composefile stop $param"
        cd $ncdir
        ;;
    host_disable)
        sudo -Eu root bash -c "systemctl -q disable nginx"
        sudo -Eu root bash -c "service nginx stop"
        sudo -Eu root bash -c "systemctl -q disable apache2"
        sudo -Eu root bash -c "service apache2 stop"
        sudo -Eu root bash -c "systemctl -q disable mysql"
        sudo -Eu root bash -c "service mysql stop"
        sudo -Eu root bash -c "systemctl -q disable redis"
        sudo -Eu root bash -c "service redis stop"
        cd $ncdir
        ;;
    dev_log)
        sudo -Eu root bash -c "docker logs -f  $3 $4 $5"
        cd $ncdir
        ;;
    dev_logs)
        sudo -Eu root bash -c "docker logs -f  $3 $4 $5"
        cd $ncdir
        ;;
    dev_clean)
        sudo -Eu root bash -c "docker container prune -f"
        cd $ncdir
        ;;
    dev_reload)
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [ $(cat /proc/sys/vm/max_map_count) != "262144" ]; then sudo sysctl -w vm.max_map_count=262144; fi
        fi
        sudo -Eu root bash -c "docker-compose -f $composefile restart $param"
        cd $ncdir
        ;;
    dev_restart)
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [ $(cat /proc/sys/vm/max_map_count) != "262144" ]; then sudo sysctl -w vm.max_map_count=262144; fi
        fi
        /bin/bash ./deploy.sh
        sudo -Eu root bash -c "docker-compose -f $composefile up --force-recreate --detach --no-deps --build  $param"
        cd $ncdir
        ;;
    dev_rebuild)
        /bin/bash ./deploy.sh
        sudo -Eu root bash -c "docker-compose -f $composefile build $param"
        ;;
    dev_deploy)
        /bin/bash ./deploy.sh
        ;;
    dev_remove)
        sudo -Eu root bash -c "docker-compose -f $composefile rm --stop $param"
        cd $ncdir
        ;;
    dev_location)
        sudo -Eu root bash -c "echo 'Working Directory Location: $myapp_dev_path'"
        cd $ncdir
        ;;
    docker_in)
        sudo -Eu root bash -c "docker exec -it $3 bash"
        cd $ncdir
        ;;
    mysql_in)
        sudo -Eu root bash -c "MYSQL_PWD=root  mysql -u root -h 127.0.0.1 -P 3307 $3_db -A"
        cd $ncdir
        ;;
    git_sync)
        /bin/bash ./gitsync.sh $3 $4
        cd $ncdir
        ;;
    db_sync)
        /bin/bash ./dbsync.sh "no-dry" $3 $4
        cd $ncdir
        ;;
    code_build)
        /bin/bash ./build.sh $3
        cd $ncdir
        ;;
    setup_config)
        tput setaf 2
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sed -i "/      overrideSystemProperties:/c\      overrideSystemProperties: false" code/configuration-store/application-dev.yml
            sed -i "/      overrideNone:/c\      overrideNone: false" code/configuration-store/application-dev.yml
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/      overrideSystemProperties: true/      overrideSystemProperties: false/g" code/configuration-store/application-dev.yml
            sed -i '' "s/      overrideNone: true/      overrideNone: false/g" code/configuration-store/application-dev.yml
        else
            echo "System Identification: Undefined"
        fi

        echo "Config Store Override Values Setted To False in application-dev.yml "
        tput sgr0
        cd $ncdir
        ;;
    setup_server)
        /bin/bash ./setup.sh server
        cd $ncdir
        ;;
    setup_es)
        /bin/bash ./setup.sh es $3
        cd $ncdir
        ;;
    setup_db)
        /bin/bash ./database.sh reinit $3
        cd $ncdir
        ;;
    import_dumps)
        /bin/bash ./database.sh dumps $3
        cd $ncdir
        ;;        
    setup_pimcore)
        /bin/bash ./pimcore/install.sh
        cd $ncdir
        ;;
    update_app)
        git pull https://$git_user:$git_pass@github.com/OitoLabs/nocapp-dev-setup.git
        cd $ncdir
        ;;
    *)
        tput setaf 3
        echo "try this ...."
        tput sgr0
        echo "Usage: nocapp dev start <blank|servicename|mode> debug <debug-port>"
        tput sgr0
        echo "Usage: nocapp dev top|kill|pause|unpause|events|start|stop|restart|remove|reload|rebuild|status|resource <blank|servicename|mode>"
        tput sgr0
        echo "Usage: nocapp dev variable|log <servicename>"
        tput sgr0
        echo "Usage: nocapp dev location"
        tput sgr0
        echo "Usage: nocapp import dumps <servicename>"
        tput sgr0
        echo "Usage: nocapp code build <blank|servicename>"
        tput sgr0
        echo "Usage: nocapp docker in <servicename>"
        tput sgr0
        echo "Usage: nocapp mysql in <servicename>"
        tput sgr0
        echo "Usage: nocapp git sync <blank|servicename>"
        tput sgr0
        echo "Usage: nocapp db sync <blank|servicename>"
        tput sgr0
        echo "Usage: nocapp update app"
        tput sgr0
        echo "Usage: nocapp setup es|server|db|pimcore|config <blank|servicename>"
        cd $ncdir
        ;;
    esac
}

#/bin/bash
# set -x
for filename in build_env/*.sh; do
    source $filename
done
mkdir -p tmp
export MYSQL_PWD=$SETUP_MYSQL_PWD

orig_cver=""
cver=""
schema_root_folder_name=""
need_to_exe_line_all_in_one=""
isDryRun=$1

next_folder_path_identify() {
    dbname=$1
    nfpi_service=$2
    nfpi_lookup=$3
    cp /dev/null $myapp_dev_path/tmp/$dbname.sql
    all_release_folders=$(ls -ltr $myapp_dev_path/code/$nfpi_service/src/main/resources/schema/ | awk '{print $9}' | sed 's/release-//g' | tr -d '.' | sort -n | sed 's/[^0-9]*//g')
    all_release_folders_list=$all_release_folders
    for val in $all_release_folders; do
        if [ $val -ge $nfpi_lookup ]; then
            # echo "Next Availabe Release Directorry:  $val"
            schema_root_folder_identify $val $nfpi_service
        fi
    done
}

schema_root_folder_identify() {
    schema_root_folder_name=""
    srfi_service=$2
    srfi_val=$1
    fn_oiginal_string_list_of_schema_release_folder=$(ls -ltr $myapp_dev_path/code/$srfi_service/src/main/resources/schema/ | awk '{print $9}')
    fn_version_schema_dir_list=$fn_oiginal_string_list_of_schema_release_folder
    for val in $fn_version_schema_dir_list; do
        fn_var_is_path_exits_current_version_schema_dir=$(echo $val | tr -d '.' | sort -n | sed 's/[^0-9]*//g' | grep $srfi_val)
        if [ $? == 0 ]; then
            fn_var_val_current_version_schema_dir=$val
            tput setaf 4
            tput bold
            # echo "Root Folder Path is: $fn_var_val_current_version_schema_dir"
            tput sgr0
            schema_root_folder_name=$fn_var_val_current_version_schema_dir
            # echo "amar $fn_var_val_current_version_schema_dir"
            new_sql_need_to_execute_found $srfi_service $fn_var_val_current_version_schema_dir
        fi

    done
}

new_sql_need_to_execute_found() {
    nsnte_service=$1
    nsnte_root_folder=$2
    nsnte_db=$(echo $1 | xargs | rev | cut -d- -f2 | rev)_db
    if [ -f $myapp_dev_path/code/$nsnte_service/src/main/resources/schema/$nsnte_root_folder/all_in_one.sql ]; then
        current_schema_found_line_all_in_one=$(cat $myapp_dev_path/code/$nsnte_service/src/main/resources/schema/$nsnte_root_folder/all_in_one.sql | grep 'source' | grep -n "\\-$orig_cver" | head -n1 | grep -Eo '^[^:]+')
        total_line_all_in_one_count=$(cat $myapp_dev_path/code/$nsnte_service/src/main/resources/schema/$nsnte_root_folder/all_in_one.sql | grep 'source' | wc -l)
        not_exected_line_all_in_one_count=$((total_line_all_in_one_count - current_schema_found_line_all_in_one))

        need_to_exe_line_all_in_one=$(cat $myapp_dev_path/code/$nsnte_service/src/main/resources/schema/$nsnte_root_folder/all_in_one.sql | grep 'source' | tail -n$not_exected_line_all_in_one_count)
        echo $need_to_exe_line_all_in_one | xargs | sed -e 's/;/;\n/g' >>$myapp_dev_path/tmp/$database.sql
        if [ $not_exected_line_all_in_one_count -gt 0 ]; then
            tput setaf 2
            tput bold
            echo "------------------------------"
            echo "☒  Database: $database"
            tput sgr0
            echo "CurrentSchemaVresion: $orig_cver"
            echo "Root Folder Path is: $nsnte_root_folder"
            tput setaf 2
            echo "DDL/DML Files Found: $not_exected_line_all_in_one_count"
            tput sgr0
            if [ $isDryRun != "dry" ]; then
                apply_pending_sql_files $nsnte_service
            fi
        else
            tput setaf 3
            echo "------------------------------"
            echo "☑  Database : $nsnte_db"
            tput sgr0
            echo "CurrentSchemaVresion: $orig_cver"
            echo "Root Folder Path is: $nsnte_root_folder"
            tput setaf 6
            echo "No DDL/DML Files Found"
            tput sgr0
        fi
    fi
}

apply_pending_sql_files() {
    apsf_service=$1
    apsf_db=$(echo $1 | xargs | rev | cut -d- -f2 | rev)_db
    echo "Executing......."
    cd $myapp_dev_path/code/$apsf_service/src/main/resources/schema/
    mysql -u root -h 127.0.0.1 -P 3307 $apsf_db <$myapp_dev_path/tmp/$database.sql
    after_cver=$(MYSQL_PWD=root mysql -Ns -h 127.0.0.1 -P 3307 -u root $apsf_db -e "select version from schema_version")
    echo "➤  NowSchemaVersion: $after_cver"
    cd $myapp_dev_path
}

if [[ -z "$2" ]]; then

    for line in $(cat service.txt); do
        orig_cver=""
        cver=""
        schema_root_folder_name=""
        need_to_exe_line_all_in_one=""
        lookupvalue=""
        repo="$(echo $line | tr ',' '\n' | head -n1 | xargs)"
        branch="$(echo $line | tr ',' '\n' | tail -n1 | xargs)"
        database=$(echo $repo | xargs | rev | cut -d- -f2 | rev)_db
        serviceName=$repo

        if [ -f "code/$repo/src/main/resources/schema/main.sql" ]; then

            orig_cver=$(MYSQL_PWD=root mysql -Ns -h 127.0.0.1 -P 3307 -u root $database -e "select version from schema_version")
            cver=$(echo "$orig_cver" | tr -d '.')
            # echo "CurrentSchemaVresion: $orig_cver"
            lookupvalue=$(echo $cver | cut -c1-4)00
            next_folder_path_identify $database $serviceName $lookupvalue
            # apply_pending_sql_files $database $serviceName
        fi
    done

else
    orig_cver=""
    cver=""
    schema_root_folder_name=""
    need_to_exe_line_all_in_one=""
    lookupvalue=""
    database=$(echo $2 | xargs | rev | cut -d- -f2 | rev)_db
    serviceName=$(echo $2 | sed 's/-service//g')
    serviceName="$serviceName-service"
    orig_cver=$(MYSQL_PWD=root mysql -Ns -h 127.0.0.1 -P 3307 -u root $database -e "select version from schema_version")
    cver=$(echo "$orig_cver" | tr -d '.')
    lookupvalue=$(echo $cver | cut -c1-4)00

    next_folder_path_identify $database $serviceName $lookupvalue
    # apply_pending_sql_files $database $serviceName
fi

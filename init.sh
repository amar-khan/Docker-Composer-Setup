#/bin/bash
export workdir=$(pwd)

for d in $(cat service.txt); do
    d="$(echo $d | tr ',' '\n' | head -n1 | xargs)"
    if [[ "$d" =~ "ui" ]]; then
        mkdir -p $workdir/artifact/$d/dist
    else
        mkdir -p $workdir/artifact/$d/
    fi
done

if grep -q development.test-internal.com /etc/hosts; then
    echo "1. domain development.test-internal.com alreday added"
else
    # sudo sh -c echo "'127.0.0.1       development.test-internal.com'" >> /etc/hosts
    echo '127.0.0.1       development.test-internal.com' | sudo tee -a /etc/hosts >/dev/null
    echo "1. local domain development.test-internal.com added"
fi
cp nocapp.sh .nocapp.sh
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sed -i '/.nocapp.sh # This_is_for_dev_myapp_setup/d' ~/.bashrc
elif [[ "$OSTYPE" == "darwin"* ]]; then
    touch ~/.bashrc ~/.zshrc
    sed -i '' '/.nocapp.sh # This_is_for_dev_myapp_setup/d' ~/.bashrc
    sed -i '' '/.nocapp.sh # This_is_for_dev_myapp_setup/d' ~/.zshrc
    echo "source $workdir/.nocapp.sh # This_is_for_dev_myapp_setup" >>~/.zshrc
fi
echo "source $workdir/.nocapp.sh # This_is_for_dev_myapp_setup" >>~/.bashrc
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sed -i '/export myapp_dev_path=/d' ~/.bashrc
elif [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/export myapp_dev_path=/d' ~/.bashrc
    sed -i '' '/export myapp_dev_path=/d' ~/.zshrc
    echo "export myapp_dev_path=$workdir" >>~/.zshrc
    source ~/.zshrc
fi
echo "export myapp_dev_path=$workdir" >>~/.bashrc
echo "2. nocapp added/updated"
ansible-vault decrypt $workdir/build_env/aws.sh $workdir/build_env/artifact.sh $workdir/config/env/aws.env
source ~/.bashrc
exec bash

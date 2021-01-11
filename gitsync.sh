#/bin/bash

cwdir=$(pwd)
echo "Setting Up Github Username and Password"
for filename in build_env/*.sh; do
  # echo "Sourcing : $filename"
  source $filename
done

if [[ -z "$1" ]]; then

  for line in $(cat service.txt); do

    repo="$(echo $line | tr ',' '\n' | head -n1 | xargs)"
    branch="$(echo $line | tr ',' '\n' | tail -n1 | xargs)"
    tput setaf 4
    echo "Sacning Repo : $repo"
    tput setaf 4
    echo "Branch : $branch"
    tput sgr0
    echo " "
    if [ -d "code/$repo" ]; then
      cd $cwdir
      # Control will enter here if $DIRECTORY exists.
      git --git-dir=code/$repo/.git --work-tree=code/$repo checkout $branch
      git --git-dir=code/$repo/.git --work-tree=code/$repo pull
    else
      git clone -b $branch https://$git_user:$git_pass@github.com/OitoLabs/$repo.git code/$repo
    fi
    cd $cwdir
  done

else

  tput setaf 4
  echo "Sacning Repo : $1"
  tput setaf 4
  echo "Branch : $2"
  tput sgr0
  echo " "
  if [ -d "code/$1" ]; then
    cd $cwdir
    # Control will enter here if $DIRECTORY exists.
    git --git-dir=code/$1/.git --work-tree=code/$1 checkout $2
    git --git-dir=code/$1/.git --work-tree=code/$1 pull
  else
    git clone -b $2 https://$git_user:$git_pass@github.com/OitoLabs/$1.git code/$1
  fi
  cd $cwdir

fi

#!/bin/ksh
repo_path=$(echo "${PWD##*/}")
repo_name="${repo_path}.git"
nickname="magusvagus"

printf "[ !!! ] This script must be run inside the dir of the target git repo\n"
printf "[ !!! ] This script requires an enabled ssh tocken of the target repo\n"

printf "Current repos in use:\n"
git remote -v

printf "Want to add additional repositories? [y/n]"
read ANSWER
if [[ $ANSWER == "n"]]; then
	printf "Quitting... \n"

elif [[ $ANSWER == "y" ]]; then
	git remote add origin https://github.com/$username/$repo_name
	git remote set-url --add --push origin git@github.com:$nickname/$repo_name
	git remote set-url --add --push origin git@gitlab.com:$nickname/$repo_name

	printf "[ OK  ] Repositories added, project is ready to push\n"




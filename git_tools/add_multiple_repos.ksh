#!/bin/ksh
repo_path=$(echo "${PWD##*/}") # extract name of current dir
repo_name="${repo_path}.git"
nickname="magusvagus"

printf "[ !!! ]\t This script must be run inside the\n\t dir of the target git repo\n"
printf "[ !!! ]\t This script requires an enabled ssh\n\t tocken of the target repo\n"

printf "\nCurrent repos in use:\n"
git remote -v

printf "\nWant to add additional repositories? [y/n]"
read ANSWER
if [[ $ANSWER == "n" ]]; then
	printf "Quitting... \n\n"
	exit

elif [[ $ANSWER == "y" ]]; then
	git remote add origin https://github.com/$username/$repo_name
	git remote set-url --add --push origin git@github.com:$nickname/$repo_name
	git remote set-url --add --push origin git@gitlab.com:$nickname/$repo_name

	printf "[ OK  ] Repositories added, project is ready to push\n"
fi




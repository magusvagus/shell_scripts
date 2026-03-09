#!/bin/ksh
REPO_PATH=$(echo "${PWD##*/}") # extract name of current dir
REPO_NAME="${REPO_PATH}.git"
NICKNAME="magusvagus"
LOOP="FALSE"

printf "[ !!! ]\t This script must be run inside the\n\t dir of the target git repo\n"
printf "[ !!! ]\t This script requires an enabled ssh\n\t tocken of the target repo\n"

printf "\nCurrent repos in use:\n"
git remote -v

while [[ $LOOP != "TRUE" ]]; do

	printf "\nWant to add additional repositories? [y/n]  "
	read ANSWER

	if [[ $ANSWER == "n" ]]; then
		printf "Quitting... \n\n"
		exit

	elif [[ $ANSWER == "y" ]]; then
		git remote add origin https://github.com/$USERNAME/$REPO_NAME
		git remote set-url --add --push origin git@github.com:$NICKNAME/$REPO_NAME
		git remote set-url --add --push origin git@gitlab.com:$NICKNAME/$REPO_NAME

		printf "[ OK  ] Repositories added, project is ready to push.\n"

	else
		printf "[ ERR ] Invalid input.\n"
	fi
done




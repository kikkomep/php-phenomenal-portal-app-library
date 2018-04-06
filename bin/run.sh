#!/usr/bin/env bash

current_path="$( cd "$(dirname "${0}")" ; pwd -P )"
converter="${current_path}/convert.sh"

path="/var/www/html/php-phenomenal-portal-app-library"
markdownFolder="$path/wiki-markdown"
htmlFolder="$path/wiki-html"
oldHtmlFolder=$(readlink -f ${htmlFolder})
newHtmlFolder="${htmlFolder}-$(date +%s)"
gitBranch="master"
remoteGitList="https://raw.githubusercontent.com/phnmnl/portal-settings/${gitBranch}/app-library/gitList.txt"

${converter} \
    --force-cleanup \
    --html "${newHtmlFolder}" \
    --md "${markdownFolder}" \
    --git-branch "${gitBranch}" \
    "${remoteGitList}"

echo "Linking new folder ${newHtmlFolder}"
ln -sfn ${newHtmlFolder} ${htmlFolder}

echo "Removing old folder ${oldHtmlFolder}"
rm -Rf ${oldHtmlFolder}
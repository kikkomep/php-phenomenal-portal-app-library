#!/usr/bin/env bash

current_path="$( cd "$(dirname "${0}")" ; pwd -P )"
converter="${current_path}/convert.sh"

path="/var/www/html/php-phenomenal-portal-app-library"
markdownFolder="$path/wiki-markdown"
htmlFolder="$path/wiki-html"
newHtmlFolder="${htmlFolder}-$(date +%s)"
gitBranch="master"
remoteGitList="https://raw.githubusercontent.com/phnmnl/portal-settings/${gitBranch}/app-library/gitList.txt"

# read the old link
if [[ -L ${htmlFolder} ]]; then
    oldHtmlFolder=$(readlink -f ${htmlFolder})
fi

# clean 'oldHtmlFolder' if it is not a directory
if [[ ! -z ${oldHtmlFolder} && ! -d ${oldHtmlFolder} ]]; then
    oldHtmlFolder=""
fi

# print path info
echo "Script path: ${current_path}"
echo "Path to the folder: ${path}"
echo "HtmlFolder: ${htmlFolder}"
echo "NewHtmlFolder: ${newHtmlFolder}"
echo "OldHtmlFolder: ${oldHtmlFolder}"

# start conversion
${converter} \
    --force-cleanup \
    --html "${newHtmlFolder}" \
    --md "${markdownFolder}" \
    --git-branch "${gitBranch}" \
    "${remoteGitList}"


# check whether there exists the new folder
if [[ -d ${newHtmlFolder} ]]; then
    echo "Linking new folder ${newHtmlFolder}"
    ln -sfn ${newHtmlFolder} ${htmlFolder}

    # remove the old folder if it exists
    if [[ ! -z ${oldHtmlFolder} && -d ${oldHtmlFolder} ]]; then
        echo "Removing old folder ${oldHtmlFolder}"
        rm -Rf ${oldHtmlFolder}
    fi
fi
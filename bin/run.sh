#!/usr/bin/env bash

current_path="$( cd "$(dirname "${0}")" ; pwd -P )"
converter="${current_path}/convert.sh"

path="/var/www/html/php-phenomenal-portal-app-library"
htmlFolder="$path/wiki-html"
markdownFolder="$path/wiki-markdown"
remoteGitList="https://raw.githubusercontent.com/phnmnl/portal-settings/master/app-library/gitList.txt"
gitBranch="master"

# set directories to host new files
timestamp="$(date +%s)"
newHtmlFolder="${htmlFolder}-${timestamp}"
newMarkdownFolder="${markdownFolder}-${timestamp}"

# read the old html link
if [[ -L "${htmlFolder}" ]]; then
    oldHtmlFolder=$(readlink -f "${htmlFolder}")
fi

# read the old markdown link
if [[ -L "${markdownFolder}" ]]; then
    oldMarkdownFolder=$(readlink -f "${markdownFolder}")
fi

# print path info
echo "Script path: ${current_path}"
echo "Target base path: ${path}"
echo "Html Folder [New]: ${newHtmlFolder}"
echo "Html Folder [Old]: ${oldHtmlFolder}"
echo "Html Folder [Link]: ${htmlFolder}"
echo "Markdown Folder [New]: ${newMarkdownFolder}"
echo "Markdown Folder [Old]: ${oldMarkdownFolder}"
echo "Markdown Folder [Link]: ${markdownFolder}"

# start conversion
${converter} \
    --force-cleanup \
    --html "${newHtmlFolder}" \
    --md "${newMarkdownFolder}" \
    --git-branch "${gitBranch}" \
    "${remoteGitList}"


# check whether there exists the new folder
if [[ -d "${newHtmlFolder}" && -d "${newMarkdownFolder}" ]]; then

    echo -e "\nCreating links to the updated resources..."
    echo " - Linking new markdown folder ${newMarkdownFolder}"
    ln -sfn "${newMarkdownFolder}" "${markdownFolder}"
    echo " - Linking new html folder ${newHtmlFolder}"
    ln -sfn "${newHtmlFolder}" "${htmlFolder}"

    # cleaning old directories
    echo -e "\nCleaning old"
    if [[ ! -z "${oldHtmlFolder}" && -d "${oldHtmlFolder}" ]]; then
        echo " - Removing old html folder ${oldHtmlFolder}"
        rm -Rf "${oldHtmlFolder}"
    fi
    if [[ ! -z "${oldMarkdownFolder}" && -d "${oldMarkdownFolder}" ]]; then
        echo " - Removing old markdown folder ${oldMarkdownFolder}"
        rm -Rf "${oldMarkdownFolder}"
    fi
fi
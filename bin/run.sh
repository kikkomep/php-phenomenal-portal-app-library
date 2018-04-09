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
if [[ -L ${htmlFolder} ]]; then
    oldHtmlFolder=$(readlink -f ${htmlFolder})
fi

# clean 'oldHtmlFolder' if it is not a directory
if [[ ! -z ${oldHtmlFolder} && ! -d ${oldHtmlFolder} ]]; then
    oldHtmlFolder=""
fi

# read the old markdown link
if [[ -L ${markdownFolder} ]]; then
    oldMarkdownFolder=$(readlink -f ${markdownFolder})
fi

# clean 'oldMarkdownFolder' if it is not a directory
if [[ ! -z ${oldMarkdownFolder} && ! -d ${oldMarkdownFolder} ]]; then
    oldMarkdownFolder=""
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
if [[ -d ${newHtmlFolder} && -d ${newMarkdownFolder} ]]; then

    echo "Linking new markdown folder ${newMarkdownFolder}"
    ln -sfn ${newMarkdownFolder} ${markdownFolder}

    echo "Linking new html folder ${newHtmlFolder}"
    ln -sfn ${newHtmlFolder} ${htmlFolder}

    # remove the old html folder if it exists
    if [[ ! -z ${oldHtmlFolder} && -d ${oldHtmlFolder} ]]; then
        echo "Removing old folder ${oldHtmlFolder}"
        rm -Rf ${oldHtmlFolder}
    fi

    # remove the old markdown folder if it exists
    if [[ ! -z ${oldMarkdownFolder} && -d ${oldMarkdownFolder} ]]; then
        echo "Removing old folder ${oldMarkdownFolder}"
        rm -Rf ${oldMarkdownFolder}
    fi
fi
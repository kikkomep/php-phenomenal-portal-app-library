#!/usr/bin/env bash

# configuration
path="/var/www/html/php-phenomenal-portal-app-library"
htmlFolder="$path/wiki-html"
markdownFolder="$path/wiki-markdown"
gitList="https://raw.githubusercontent.com/phnmnl/portal-settings/master/app-library/gitList.txt"
gitBranch="master"

# path of this script
current_path="$( cd "$(dirname "${0}")" ; pwd -P )"

# launch converter
"${current_path}/markdown2html/run.sh" \
    --force-cleanup \
    --html "${htmlFolder}" \
    --md "${markdownFolder}" \
    --git-branch "${gitBranch}" \
    "${gitList}"
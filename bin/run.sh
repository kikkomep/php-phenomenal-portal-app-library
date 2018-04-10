#!/usr/bin/env bash

set -o errexit

function log() {
  echo -e "$(date +"%F %T") [${BASH_SOURCE}] -- $@" >&2
}

function remove_folder(){
    local type=${1}
    local path=${2}
    if [[ ! -z "${path}" && -d "${path}" ]]; then
        echo " - Removing ${type} folder ${path}"
        rm -Rf "${path}"
    fi
}

function remove_old_folders(){
    if [[ -d "${oldHtmlFolder}" || -d "${oldMarkdownFolder}" ]]; then
        echo -e "\nCleaning: removing old folders..."
        remove_folder "old html" ${oldHtmlFolder}
        remove_folder "old markdown" ${oldMarkdownFolder}
    fi
}


function update_links(){
    # check whether there exists the new folder (redundant)
    if [[ -d "${newHtmlFolder}" && -d "${newMarkdownFolder}" ]]; then
        echo -e "\nCreating links to the updated resources..."
        echo " - Linking new markdown folder ${newMarkdownFolder}"
        ln -sfn "${newMarkdownFolder}" "${markdownFolder}"
        echo " - Linking new html folder ${newHtmlFolder}"
        ln -sfn "${newHtmlFolder}" "${htmlFolder}"
    fi
}


function on_interrupt(){
    interrupt_code="${1}"
}

function on_error(){
    log "Error at line ${BASH_LINENO[0]} running command ${BASH_COMMAND}"
}


function on_exit(){
    # cleanup temp folders if the process is interrupted
    if [[ ! -z ${interrupt_code} ]]; then
        log "Interrupted by signal ${1}"
        exit 130
    fi
    # cleanup temp folders if the process fails and notify the error code
    if [[ -z ${converter_exit_code} || ${converter_exit_code} -ne 0 ]]; then
        exit 99
    fi
    # update links and remove old resources
    # if the conversion process is OK
    update_links
    remove_old_folders
    exit 0
}

# cleanup temporary data if the process fails
trap on_error ERR

# cleanup temporary data if the process is interrupted
trap on_interrupt INT TERM

# register handler to finalize results on exit
trap on_exit EXIT

# base paths
current_path="$( cd "$(dirname "${0}")" ; pwd -P )"
converter="${current_path}/convert.sh"

# global settings
path="/var/www/html/php-phenomenal-portal-app-library"
htmlFolder="$path/wiki-html"
markdownFolder="$path/wiki-markdown"
remoteGitList="https://raw.githubusercontent.com/phnmnl/portal-settings/master/app-library/gitList.txt"
remoteGitList="/tmp/remoteGitList.txt"
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

# get the converter exit code
converter_exit_code=$?
echo "Converter exit code: ${converter_exit_code}"
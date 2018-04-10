#!/usr/bin/env bash

set -o errexit

function log() {
  echo -e "$(date +"%F %T") [${BASH_SOURCE}] -- $@" >&2
}


function on_error(){
    log "Error at line ${BASH_LINENO[0]} running command ${BASH_COMMAND}"
    if [[ ! -z ${container_name} ]]; then
        log "Conversion of the container '${container_name}' failed!"
    fi
}


function on_exit(){
    # remove downloaded list of repositories
    if [[ ! -z "${remoteGitList}" ]]; then
        echo -e "\nCleaning: removing temp list of repositories..."
        rm ${gitList}
    fi
}

# set error handler
trap on_error ERR

# log exit handler
trap on_exit EXIT

# compute an absolute path
function absPath(){
    if [[ -d "$1" ]]; then
        cd "$1"
        echo "$(pwd -P)"
    else
        cd "$(dirname "$1")"
        echo "$(pwd -P)/$(basename "$1")"
    fi
}

# convert md files of a git repo into html
function convert_markdown(){
    local source_path="${1}"
    local target_path="${2}"
    # ensure an empty target folder
    rm -Rf "${target_path}" && mkdir -p "${target_path}";
    # perform the conversion of .md files
    for file in `ls "${source_path}"`;
    do
        file=$(basename "${file}")
        filename="${file%.*}"
        extension="${file##*.}"
        if [[ ! -d "${file}" ]] && [[ ${extension} = "md" ]]; then
          echo "Converting ${file} to ${filename}${targetExtension}..."
          markdown2 --extras fenced-code-blocks \
                    "${source_path}/$file" > "${target_path}/${filename}${targetExtension}"
      fi
    done
}

# print usage
function print_usage(){
    echo -e "\nUSAGE: ${0} [--force-cleanup] [--html <PATH>] [--md <PATH>] [--git-branch <BRANCH_NAME>] <REPOSITORIES_LIST_FILE>\n"  
}

# set defaults
markdownFolder="wiki-markdown"
htmlFolder="wiki-html"
gitList="conf/gitList.txt"
gitBranch="master"
targetExtension=".html"
forceCleanup=false

# Collect arguments to be passed on to the next program in an array, rather than
# a simple string. This choice lets us deal with arguments that contain spaces.
ARGS=()

# parse arguments
while [ -n "$1" ]; do
    # Copy so we can modify it (can't modify $1)
    OPT="$1"
    # Detect argument termination
    if [ x"$OPT" = x"--" ]; then
            shift
            for OPT ; do
                    # append to array
                    ARGS+=("$OPT")
            done
            break
    fi
    # Parse current opt
    while [ x"$OPT" != x"-" ] ; do
            case "$OPT" in
                  -h | --help )
                          print_usage
                          exit 0
                          ;;
                  --force-cleanup )
                          forceCleanup=true
                          ;;
                  --html=* )
                          htmlFolder="${OPT#*=}"
                          shift
                          ;;
                  --html )
                          htmlFolder="$2"
                          shift
                          ;;
                  --md=* )
                          markdownFolder="${OPT#*=}"
                          shift
                          ;;
                  --md )
                          markdownFolder="$2"
                          shift
                          ;;
                  --git-branch=* )
                          gitBranch="${OPT#*=}"
                          shift
                          ;;
                  --git-branch )
                          gitBranch="$2"
                          shift
                          ;;
                  * )
                          # append to array
                          ARGS+=("$OPT")
                          break
                          ;;
            esac
            break
    done
    # move to the next param
    shift
done

# set and trim the REPOSITORIES_LIST_PARAMETER containing the list of git repositories
gitList=$(echo "${ARGS//[[:space:]]/}")

# check whether gitList parameter has been provided
if [[ -z "${gitList}" ]]; then
    echo -e "\nYou need to provide the <REPOSITORIES_LIST_FILE> !!!\n"
    exit -1
fi

# log configuration
echo -e "\n-------------------------------------------------------------------------------------------------------"
echo -e "*** Tool Configuration *** "
echo -e "-------------------------------------------------------------------------------------------------------"
echo "Markdown folder: ${markdownFolder}"
echo "Html folder: ${htmlFolder}"
echo "Git Repositories file: ${gitList}"
echo "Git branch: ${gitBranch}"
echo -e "-------------------------------------------------------------------------------------------------------"

# download the list file if it is a HTTP(s) resource
if [[ ! -z "${gitList}" && "${gitList}" =~ ^https?://.+  ]]; then
    echo -e "Downloading list of repositories..."
    remoteGitList="${gitList}"
    gitList=$(mktemp)
    wget -O "${gitList}" "${remoteGitList}"
    echo "Downloading list of repositories... DONE"
fi

# Check whether the gitList file exists or not
if [[ ! -f "${gitList}" ]]; then
    echo "GitList file '${gitList}' doesn't exist!!!"
    exit -1
fi

# force absolute paths
htmlFolder=$(absPath "${htmlFolder}")
markdownFolder=$(absPath "${markdownFolder}")
gitList=$(absPath "${gitList}")

# create required folder if they don't exist
mkdir -p "${markdownFolder}"
mkdir -p "${htmlFolder}"

# set markdown folder as working dir
cd "${markdownFolder}"

# process list of container repositories
while IFS= read line
do
    # skip blank lines
    if [[ ! -z ${line} ]]; then
        # extract the container name
        container_name=$(echo ${line} | sed -e 's/https:\/\/\([^\/]\+\)\/\([^\/]\+\)\/\(.*\)\.git/\3/g')
        echo -e "\nProcessing container '$container_name'..." 
        # if the repository already exists simply update it
        # otherwise it will be cloned
        if [[ -d "${container_name}" && ! ${forceCleanup} ]]; then
            echo "Updating existing repository..." 
            cd "${container_name}" && git pull origin "${gitBranch}" && cd ..
        else
            # cleanup existing git repositories is required
            if [[ -d "${container_name}" ]]; then
                echo "Cleaning existing repositories..."
                rm -Rf "${container_name}"
                echo "Cleaning existing repositories... DONE"
            fi
            # download the repository
            git clone --depth 1 -b "${gitBranch}" "$line"
        fi
        # convert markdown
        convert_markdown "./${container_name}" "${htmlFolder}/${container_name}"
        echo -e "Processing container '$container_name'... DONE" 
        # wait before the next conversion job
        sleep 5
    fi
done <"$gitList"
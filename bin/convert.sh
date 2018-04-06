#!/usr/bin/env bash

set -o errexit
set -o nounset

# path of the markdown2 utility
markdown2="/usr/local/bin/markdown2"

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
    local container_name="${1}"
    if [[ -d ${htmlFolder}/${container_name} ]]; then rm -Rf ${htmlFolder}/${container_name}; fi;
    mkdir -p "${htmlFolder}/${container_name}";
    for file in `ls ./${container_name}`;
    do
        file=$(basename "${file}")
        filename="${file%.*}"
        extension="${file##*.}"
        if [[ ! -d "${file}" ]] && [[ ${extension} = "md" ]]; then
          echo "Converting ${file} to ${filename}${targetExtension}..."
          ${markdown2} --extras fenced-code-blocks \
                    "${container_name}/$file" > "$htmlFolder/${container_name}/${filename}${targetExtension}"
      fi
    done
}


# print usage
function print_usage(){
    echo -e "\nUSAGE: ${0} [--force-cleanup] [--html <PATH>] [--md <PATH>] [--git-branch <BRANCH_NAME>] <REPOSITORIES_LIST_FILE>\n"  >&2
}

# set defaults
markdownFolder="wiki-markdown"
htmlFolder="wiki-html"
gitList="conf/gitList.txt"
gitBranch="master"
targetExtension=".html"
forceCleanup=false

# parse arguments
OTHER_OPTS=''
while [ $# -gt 0 ]; do
    # Copy so we can modify it (can't modify $1)
    OPT="$1"
    # Detect argument termination
    if [ x"$OPT" = x"--" ]; then
            shift
            for OPT ; do
                    OTHER_OPTS="$OTHER_OPTS \"$OPT\""
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
                          OTHER_OPTS="$OTHER_OPTS $OPT"
                          break
                          ;;
            esac
            # Check for multiple short options
            # NOTICE: be sure to update this pattern to match valid options
            NEXTOPT="${OPT#-[cfr]}" # try removing single short opt
            if [ x"$OPT" != x"$NEXTOPT" ] ; then
                    OPT="-$NEXTOPT"  # multiple short opts, keep going
            else
                    break  # long form, exit inner loop
            fi
    done
    # move to the next param
    shift
done

# set and trim the REPOSITORIES_LIST_PARAMETER containing the list of git repositories
gitList=$(echo "${OTHER_OPTS//[[:space:]]/}")

# check whether gitList parameter has been provided
if [[ -z ${gitList} ]]; then
    echo -e "\nYou need to provide the <REPOSITORIES_LIST_FILE> !!!\n"
    exit -1
fi

# download the list file if it is a HTTP(s) resource
if [[ ! -z ${gitList} && ${gitList} =~ ^https?://.+  ]]; then
    remoteGitList=${gitList}
    gitList="/tmp/remoteGitList.txt"
    wget -O ${gitList} ${remoteGitList}
fi

# Check whether the gitList file exists or not
if [[ ! -f ${gitList} ]]; then
    echo "GitList file '${gitList}' doesn't exist!!!"
    exit -1
fi

# force absolute paths
htmlFolder=$(absPath "${htmlFolder}")
markdownFolder=$(absPath "${markdownFolder}")
echo "${gitList}"
gitList=$(absPath "${gitList}")

# create required folder if they don't exist
mkdir -p ${markdownFolder}
mkdir -p ${htmlFolder}

# log configuration
echo -e "\n-------------------------------------------------------------------------------------------------------" >&2
echo -e "*** Tool Configuration *** " >&2
echo -e "-------------------------------------------------------------------------------------------------------" >&2
echo "Markdown folder: ${markdownFolder}" >&2
echo "Html folder: ${htmlFolder}" >&2
echo "Git Repositories file: ${gitList}" >&2
echo "Git branch: ${gitBranch}" >&2
echo -e "-------------------------------------------------------------------------------------------------------" >&2

# set markdown folder as working dir
cd ${markdownFolder}

# cleanup existing git repositories is required
if [[ ${forceCleanup} = true ]]; then
    echo "Cleaning existing repositories..." >&2
    rm -Rf *
    echo "Cleaning existing repositories... DONE" >&2
fi

# process list of container repositories
while IFS= read line
do
    # skip blank lines
    if [[ ! -z ${line} ]]; then
        # extract the container name
        container_name=$(echo ${line} | sed -e 's/https:\/\/\([^\/]\+\)\/\([^\/]\+\)\/\(.*\)\.git/\3/g')
        echo -e "\nProcessing container '$container_name'..." >&2
        # if the repository already exists simply update it
        # otherwise it will be cloned
        if [[ -d ${container_name} ]]; then
            echo "Updating existing repository..." >&2
            cd ${container_name} && git pull origin ${gitBranch} && cd ..
        else
            git clone -b ${gitBranch} "$line"
        fi
        # convert markdown
        convert_markdown "${container_name}"

        echo -e "Processing container '$container_name'... DONE" >&2
    fi
done <"$gitList"
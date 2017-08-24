#!/usr/bin/env bash
path="/var/www/html/php-phenomenal-portal-app-library"
markdownFolder="$path/wiki-markdown"
htmlFolder="$path/wiki-html"
gitList="$path/conf/gitList.txt"
extension=".html"

source $path/conf/branch.config
if [ -z ${BRANCH+x} ]; then
  echo "BRANCH var is unset, setting to default master"
  BRANCH=master
fi

echo "Using $BRANCH branch for portal settings and README files"

wget -O $gitList https://raw.githubusercontent.com/phnmnl/portal-settings/$BRANCH/app-library/gitList.txt

mkdir -p $markdownFolder
mkdir -p $htmlFolder

cd $markdownFolder && rm -rf *

echo $gitList

while IFS= read line
do
    git clone -b $BRANCH --depth 1 "$line"
done <"$gitList"

PATH=/usr/local/bin/:$PATH

for dir in `ls ./`;
do
    for file in `ls ./$dir`;
    do
      filename="${file%.*}"
      mkdir -p "$htmlFolder/$dir" && markdown2 --extras fenced-code-blocks "$dir/$file" > "$htmlFolder/$dir/$filename"
      markdown2 --extras fenced-code-blocks "$dir/$file" > "$htmlFolder/$dir/$filename$extension"
    done
done

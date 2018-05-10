# App Library Backend
Version 1.1.0

## Installation
Make sure Python is install in the unix based system.

Install markdown 2

    pip3.5 install markdown2

Using just pip would also be sufficient

Open `/bin/run.sh`, change path to the absolute path of the hosting folder

Initialise by running the following under your hosting folder

    ./bin/run.sh

Setting permission of `bin` `conf` to be 644, other folders can be set as 755

`path` in `bin` needs to be set.

## Notes

* This repository uses a Git submodule. To easily initialize and update 
the submodule pass the option `--recurse-submodules` 
to the `git clone` command.

* If crontab is used, the absolute location of markdown2 needs to be specified

## Changelog

##### Updates v1.1.0
Update search functions to implement conjunctive queries
Integrate `markdown2html` as a conversion tool 
Add new script to convert markdown to HTML

##### Updates v0.3.1
Improve bash
Add full text search

##### Updates v0.2.2
Add query string to redirect pages

##### Updates v0.2.1
Production version

##### Updates v0.2
Data can be pulled across and displayed

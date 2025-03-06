#!/usr/bin/env bash
#
# copy final scripts AND DATA
# to git repo for commit/push
#
REPO_DIR="../../../ICTVdatabase/data/"

exec rsync $* -hav --progress --exclude='*~' --no-recursive ./*.utf8.osx.txt ./*.bat ./*.sh "$REPO_DIR"

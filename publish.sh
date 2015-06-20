#!/bin/sh

PWD=$(cd "$(dirname "$0")"; pwd)
VERSION=`cat manifest.json | jq .version | tr -d [\"]`

APP=`cat manifest.json | jq .name | tr -d [\"]`

tar -cvzf ../$APP.$VERSION.tar.gz . --exclude '.git' --exclude "publish.sh" --exclude "*.mpk" --exclude "\#*" --exclude "*~"

mv -f ../$APP.$VERSION.tar.gz $APP.$VERSION.mpk

#!/bin/sh
find . -name ".DS_Store" -print0 | xargs -t0 rm
rm -rf `find . -type d -name .svn`

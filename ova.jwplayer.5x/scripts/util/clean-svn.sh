#!/bin/sh
echo "recursively removing .svn folders from src and examples"
rm -rf `find ../src -type d -name .svn`


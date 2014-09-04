#!/bin/sh

find . -exec grep -l “${0}” {} \;

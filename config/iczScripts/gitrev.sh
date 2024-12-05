#!/bin/bash
echo "bump project version"
revisioncount=`git log --oneline | wc -l | tr -d ' '`
projectversion=`git describe --tags --long`
cleanversion=${projectversion%%-*}

echo "$projectversion-$revisioncount"
echo "$cleanversion.$revisioncount"
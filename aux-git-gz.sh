#!/bin/bash

function usage {
	echo "gen <output>.tar.gz for git ref <ref>"
	echo "$0 <ref> <output>"
}
ref=$1
output=$2
if [ -z "$ref" ]
then
	usage
	exit
fi
if [ -z "$output" ]
then
	usage
	exit
fi
git archive --format=tar $ref | gzip > $output.tar.gz
echo $output.tar.gz

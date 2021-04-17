#!/bin/bash

function sendHelp {
	echo "Minecraft Jar Getter is a simple™ tool for downloading and merging the Minecraft client and server jars"
	echo "Use ./merge <version> to get the merged jar for the desired version"
	echo "Example: \"./merge 21w15a\" will output minecraft-21w15a-merged.jar"
}

if [[ $1 == "" ]]; then
	sendHelp
fi

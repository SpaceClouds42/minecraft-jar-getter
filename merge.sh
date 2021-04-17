#!/bin/bash

# $1 is the exit code
# Sends a help message and ends script
function sendHelp {
	echo "Need help?"
	echo "./merge.sh <version> to get the merged jar for the desired version"
	echo "./merge.sh (-r|-s)"
	echo "  -r: latest release"
	echo "  -s: latest snapshot"
	exit $1
}

# $1 is version type argument (release or snapshot)
# Gets the latest release/snapshot from mojang launchermeta
# returns the latest version
function getLatestVer {
	if [[ $1 == -r ]]; then
		latest=$(curl https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "\"release\": \"\K.*?(?=\")")
	elif [[ $1 == -s ]]; then
		latest=$(curl https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "\"snapshot\": \"\K.*?(?=\")")
	fi
	echo $latest
}

# $1 is the version
# Gets the version meta for version $1
function getVerMeta {
	echo $(curl https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "id\": \"$1\".+?l\": \"\K.+?$1\.json")
}

# $1 is the version meta
# Downloads the client jar to /tmp/client-$1.jar
function downloadClient {
	echo "Totally downloading client.jar"
}

# $1 is the version meta
# Downloads the server jar to /tmp/server-$1.jar
function downloadServer {
	echo "Totally downloading server.jar"
}

mcVer=""
##########################
#                        #
# Merge.sh Input Handler #
#                        #
##########################
# No arg or help arg
if [[ $1 == "" || $1 == -h || $1 == --help ]]; then
	sendHelp 0

# Latest release or snapshot arg
elif [[ $1 == -r || $1 == -s ]]; then
	mcVer=$(getLatestVer $1)

# Version arg
elif [[ $(curl https://launchermeta.mojang.com/mc/game/version_manifest.json -L) == *$1*  ]]; then
	mcVer=$1

# Version not found
else
	echo "Version $@ does not exist"
        echo
        sendHelp 1
fi

meta=$(getVerMeta $mcVer)
downloadClient $meta
downloadServer $meta

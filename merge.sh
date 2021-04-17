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
		latest=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "\"release\": \"\K.*?(?=\")")
	elif [[ $1 == -s ]]; then
		latest=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "\"snapshot\": \"\K.*?(?=\")")
	fi
	echo $latest
}

# $1 is the version
# Gets the version meta for version $1
function getVerMeta {
	echo $(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json -L | grep -Po "id\": \"$1\".+?l\": \"\K.+?$1\.json")
}

# $1 is the version meta
# $2 is client or server
# $3 is the mc version
# Downloads the $2 jar to /tmp/$3-$2.jar
function downloadMcJar {
	echo "Downloading $3-$2.jar..."

	hash=$(curl -s $1 -L | grep -Po "$2\": {\"sha1\": \"\K.+?(?=\")")
	mkdir tmp -p
	cd tmp
	curl -s https://launcher.mojang.com/v1/objects/$hash/$2.jar > $3-$2.jar
	cd ..

	localHash=$(sha1sum tmp/$3-$2.jar | grep -Po ".+(?= )")
	if [[ "$hash " == $localHash ]]; then
		echo "Downloaded $3-$2.jar. Hash verified. Size: $(ls -lah tmp/$3-$2.jar | awk '{print $5}')"
	else
		rm tmp/$3-$2.jar
		echo "Downloaded $3-$2.jar. Hashes did not match! Removed file"
		echo "API says hash should be: $hash"
		echo "Local file's hash is:    $localHash"
	fi
}

# $1 is the path to first jar
# $2 is the path to second jar
# $3 is the output jar name
# Merges the two jars into one output jar and deletes input jars
function mergeJars {
	echo "Merging jars $1 and $2"

	oldJavaOpts=$JAVA_OPTS
	# Without doing this, the merge task will run out of memory and crash
  export JAVA_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/dump.hprof"
	kotlinc -script src/mergeJars.main.kts -- -a $1 -b $2 -o $3 >/tmp/null 2>/tmp/null
	# I don't want to undo someone's java options if they've fine tuned them
	export JAVA_OPTS=$oldJavaOpts

	echo "Merged jar: $3"
}

mcVer=""

##########################
# Merge.sh Input Handler #
##########################

# No arg or help arg
if [[ $1 == "" || $1 == -h || $1 == --help ]]; then
	sendHelp 0

# Latest release or snapshot arg
elif [[ $1 == -r || $1 == -s ]]; then
	mcVer=$(getLatestVer $1)
	if [ $1 = -r ]; then
		echo "Latest release is $mcVer"
	else
		echo "Latest snapshot is $mcVer"
	fi
	echo

# Version arg
elif [[ $(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json -L) == *"id\": \"$1\""*  ]]; then
	mcVer=$1

# Version not found
else
	echo "Version $@ does not exist"
        echo
        sendHelp 1
fi

meta=$(getVerMeta $mcVer)
downloadMcJar $meta client $mcVer
echo
downloadMcJar $meta server $mcVer
echo
mergeJars tmp/$mcVer-client.jar tmp/$mcVer-server.jar $mcVer-merged.jar

if [[ $2 == "--keep" ]]; then
  rm tmp/dump.hprof
else
  rm tmp -rf
fi
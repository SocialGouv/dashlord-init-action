#!/bin/sh

#
# check wether dashlord.yml or urls.txt exist and output a proper list of urls as JSON
#
function parseConfig() {
    if [[ -e "dashlord.yaml" ]]
    then
        # echo "parse dashlord.yaml"
        URLS=$(yq e ".urls[].url" dashlord.yaml)
    elif [[ -e "dashlord.yml" ]]
    then
        # echo "parse dashlord.yml"
        URLS=$(yq e ".urls[].url" dashlord.yaml)
    elif [[ -e "urls.txt" ]]
    then
        # echo "parse urls.txt"
        URLS=$(cat urls.txt)
    fi

    URLS=$(echo "$URLS" | grep -e "^http" | grep -v "^\s*#")
    URLS="${URLS//'%'/'%25'}"

    URLS_JSON=$(echo "$URLS" | jq -Rsc 'split("\n") [0:-1]' -)

    echo $URLS_JSON
}

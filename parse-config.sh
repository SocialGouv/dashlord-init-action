#!/bin/bash

#
# check wether dashlord.yml or urls.txt exist and output a proper list of urls as JSON
#
function parseConfig {
    if [[ -e "dashlord.yaml" ]]; then
        # echo "parse dashlord.yaml"
        URLS=$(yq e ".urls[].url" dashlord.yaml)
    elif [[ -e "dashlord.yml" ]]; then
        # echo "parse dashlord.yml"
        URLS=$(yq e ".urls[].url" dashlord.yml)
    elif [[ -e "urls.txt" ]]; then
        # echo "parse urls.txt"
        URLS=$(cat urls.txt)
    fi

    URLS=$(echo "$URLS" | grep -e "^http" | grep -v "^\s*#")

    # check if there's some new urls in the config
    if [[ -e "./results" ]]; then
        NEW_URLS=()
        for URL in $URLS; do
            URL_BASE64=$(printf "%s" "$URL" | base64 -w 500) # default is wrap at 76, on osx its '-b', on linux '-w'
            if [[ ! -e "./results/$URL_BASE64" ]]; then
                NEW_URLS+=($URL)
            fi
        done;
        # we have some new urls, try these first
        if [ ${#NEW_URLS[@]} -gt 0 ]; then
            URLS=$(printf "%s\n"  "${NEW_URLS[@]}")
        fi
    fi

    URLS="${URLS//'%'/'%25'}"
    URLS_JSON=$(echo "$URLS" | jq -Rsc 'split("\n") [0:-1]' -)

    echo $URLS_JSON
}

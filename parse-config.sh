#!/bin/bash

function parseRepositories() {
    local URL="$1"
    local REPOS_URLS="$2"
    local i="$3"
    ARRAY_URLS=[]
    IFS=';' read -ra ARRAY_REPO_URL <<< "$URL"
    if [[ ${#ARRAY_REPO_URL[*]} -gt 1 ]]; then
        ARRAY_URLS[$i]=${ARRAY_REPO_URL[0]}
        REPOS_URL=$(jq -n --arg url "${ARRAY_REPO_URL[0]}" '[{url: $url, repositories: []}]')
        IFS=',' read -ra ARRAY_REPOS <<< "${ARRAY_REPO_URL[1]}"
        for REPO in "${ARRAY_REPOS[@]}"; do
            REPOS_URL=$(echo "$REPOS_URL" | jq --argjson repos "$REPOS_URL" --arg url "${ARRAY_REPO_URL[0]}" --arg repo "$REPO" '.[] | select(.url==$url) | .repositories += [$repo]' | jq -s '.')
        done
        REPOS_URLS=$(jq -n --argjson url "$REPOS_URL" --argjson urls "$REPOS_URLS" '$urls + $url')
    else
        ARRAY_URLS[$i]="$URL"
        REPOS_URLS=$(jq -n --arg url "$URL" --argjson repos "$REPOS_URLS" '$repos + [{url: $url}]')
    fi
    echo "$REPOS_URLS"
}

#
# check wether dashlord.yml or urls.txt exist and output a proper list of urls as JSON
#
function parseConfig() {
    if [[ -e "dashlord.yaml" ]]; then
        # echo "parse dashlord.yaml"
        URLS=$(yq e ".urls[].url" dashlord.yaml)
        JSON_URLS=$(yq e -j "." dashlord.yaml)
        URLS=$(echo "$URLS" | grep -e "^http" | grep -v "^\s*#")
        JSON_URLS=$(echo "$JSON_URLS" | jq '.urls | .[] | select(.url | test("http"; "ix")) | {url: .url, repositories: .repositories} | with_entries(select(.value != null))' | jq -s '.')
    elif [[ -e "dashlord.yml" ]]; then
        # echo "parse dashlord.yml"
        URLS=$(yq e ".urls[].url" dashlord.yml)
        JSON_URLS=$(yq e -j "." dashlord.yml)
        URLS=$(echo "$URLS" | grep -e "^http" | grep -v "^\s*#")
        JSON_URLS=$(echo "$JSON_URLS" | jq '.urls | .[] | select(.url | test("http"; "ix")) | {url: .url, repositories: .repositories} | with_entries(select(.value != null))' | jq -s '.')
    elif [[ -e "urls.txt" ]]; then
        # echo "parse urls.txt"
        URLS=$(cat urls.txt)
        URLS=$(echo "$URLS" | tr '\n' '|')
        IFS='|' read -ra ARRAY_REPOS_URLS <<< "$URLS"
        mapfile -d $'\0' -t ARRAY_REPOS_URLS < <(printf '%s\0' "${ARRAY_REPOS_URLS[@]}" | grep -Pzv "^\s*#")
        mapfile -d $'\0' -t ARRAY_REPOS_URLS < <(printf '%s\0' "${ARRAY_REPOS_URLS[@]}" | grep -Pze "^http")
        REPOS_URLS='[]'
        i=0
        for URL in "${ARRAY_REPOS_URLS[@]}"; do
            REPOS_URLS=$(parseRepositories "$URL" "$REPOS_URLS" "$i")
            i=$i+1
        done
        JSON_URLS=$REPOS_URLS
    fi


    # check if there's some new urls in the config
    if [[ -e "./results" ]]; then
        NEW_URLS=()
        for URL in "${ARRAY_URLS[@]}"; do
            URL_BASE64=$(printf "%s" "$URL" | base64 -w 500) # default is wrap at 76, on osx its '-b', on linux '-w'
            if [[ ! -e "./results/$URL_BASE64" ]]; then
                NEW_URLS+=("$URL")
            fi
        done;
        # we have some new urls, try these first
        if [ ${#NEW_URLS[@]} -gt 0 ]; then
            URLS=$(printf "%s\n"  "${NEW_URLS[@]}")
        fi
    fi

    URLS="${URLS//'%'/'%25'}"
    URLS_JSON=$JSON_URLS

    echo "$URLS_JSON"
}

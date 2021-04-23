#!/bin/bash
set -e

cd "$(dirname "$0")"

source ./../../parse-config.sh

EXPECTED='[
  {
    "url": "https://www.free.fr",
    "repositories": [
      "iliad/free-ui",
      "iliad/free-api"
    ]
  }
]'
URL="https://www.free.fr;iliad/free-ui,iliad/free-api"
REPOS_URLS='[]'
i=0
RES=$(parseRepositories "$URL" "$REPOS_URLS" "$i")

echo "Should parse url;repo1,repo2 correctly"
if [[ "$RES" != "$EXPECTED" ]]
then
    echo "TXT config parse fail"
    echo "Received: $RES"
    echo "Expected: $EXPECTED"
    exit 1
else
    echo "OK"
fi

exit 0
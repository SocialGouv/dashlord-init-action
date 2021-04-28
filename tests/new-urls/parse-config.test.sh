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
  },
  {
    "url": "http://chez.com",
    "repositories": [
      "ici/chez-ui",
      "ici/chez-api"
    ]
  }
]'
RES=$(parseConfig)

echo "Should priorize new urls in the config"
if [[ "$RES" != "$EXPECTED" ]]
then
    echo "YAML config parse fail"
    echo "Received: $RES"
    echo "Expected: $EXPECTED"
    exit 1
else
    echo "OK"
fi

exit 0
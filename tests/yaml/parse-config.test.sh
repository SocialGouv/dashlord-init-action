#!/bin/sh
set -e

cd $(dirname $0)

source ./../../parse-config.sh

EXPECTED='[ { "url": "https://www.free.fr", "repositories": [ "iliad/free-ui", "iliad/free-api" ] }, { "url": "http://chez.com" } ]'
RES=$(parseConfig)

echo "Should parse YAML correctly"
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
#!/bin/sh
set -e

cd $(dirname $0)

source ./../../parse-config.sh

EXPECTED='["http://chez.com"]'
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
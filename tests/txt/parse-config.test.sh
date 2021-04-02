#!/bin/sh

cd $(dirname $0)
source ./../../parse-config.sh

EXPECTED='["https://www.free.fr","http://chez.com"]'
RES=$(parseConfig)

echo "Should parse urls.txt correctly"
if [[ "$RES" != "$EXPECTED" ]]
then
    echo "TXT config parse fail"
    echo "Received: $RES"
    echo "Expected: $EXPECTED"
    exit 1
fi

exit 0
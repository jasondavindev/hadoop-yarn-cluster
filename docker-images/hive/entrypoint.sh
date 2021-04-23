#!/bin/bash
if [ ! test -f populated ]; then
    schematool -dbType postgres -initSchema
    touch populated
fi

exec "$@" &
yarn nodemanager

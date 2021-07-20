#!/bin/bash

while read uuid; do
  ../gn-tool/gn-tool.sh -r $uuid -o export -l $2 -g https://catalogue.aodn.org.au/geonetwork -u admin -p aN2x8DGf
done <$1



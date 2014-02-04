## Prerequisites

* siege

## About

### siege_geoserver_urls

The script `siege_geoserver_urls.sh` does the following:
 * Generates a full list of `GetFeature` and `GetMap` requests;
 * Runs `siege` against this list (passing through command line parameters)

### replay_attack
The script `replay_attack.sh` does the following:
 * Downloads an `access.log` file and replay it against a different geoserver

Example usage to attack `http://geoserver-rc.aodn.org.au/geoserver` with a replay from `11-nsp-mel`:
```
./replay_attack.sh -u http://geoserver-rc.aodn.org.au/geoserver -s /geoserver -f 11-nsp-mel.emii.org.au:/mnt/ebs/log/apache2/geoserver-123-11-nsp-mel.aodn.org.au-access.log
```

## Scenarios

TODO :-)


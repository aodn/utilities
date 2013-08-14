# GeoeNetwork Utilities

## geonetwork_find_and_replace.sh
Used to replace text in **all** metadata records.

## TL;DR
`psql -h $host -d imosmest -U $user -W -c "update metadata set data = replace(data, 'search string', 'replace string');"`

### Usage
Edit the file `geonetwork_find_and_replace.sh` and substitute your values into `search string` and `replace string`.

Scp the file to the host where the database is
`$ scp geonetwork_find_and_replace.sh mydbhost:`

Make sure you are sshd into the host where the database is
`$ ssh mydbhost`

You may need to `sudo` to an appropriate user if you do not have privileges to connect to the database, if that is the case the file will need to be executable by said user
`$ mv geonetwork_find_and_replace.sh /tmp`
`$ chmod 755 /tmp/geonetwork_find_and_replace.sh`
`$ sudo postgres`

Then run it
`/tmp/geonetwork_find_and_replace.sh`

#### Other
Some effort had been put in to wrapping this in a bash script but when spaces are required in the search and replace string bash treats them as options unless they are escaped, as this is more effort than it is worth this wrapper was abandoned. Better scripters than me are welcome to try. My attempt is in this repo as `failed_geonetwork_find_and_replace.sh`.

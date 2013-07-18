## Link Checker Scripts
This folder contains scripts to check for broken and incorrect links.

Ruby scripts expect Bundler (http://bundler.io/) to be installed.

### cat_geoserver_links

**cat_geoserver_links** - concatenate links from a given geoserver.

	Usage: cat_geoserver_links <server URL> [options]
	    -h, --help                       Display this screen
	    -v, --verbose                    Verbose logging

#### Examples

	$ cd lib
	$ ./cat_geoserver_links.rb http://geoserver.imos.org.au/geoserver
	http://mest.aodn.org.au/geonetwork/srv/en/metadata.show?uuid=c13451a9-7cfc-091c-e044-00144f7bc0f4
	http://geoserver.imos.org.au/geoserver/wfs?service=wfs&version=1.1.0&request=GetFeature&typeName=imos:csiro_harvest_nrs_biomass&srs=EPSG:4326&outputFormat=csv&cql_filter=(station_name='Maria Island')
	mailto:Claire.Davies@csiro.au
	...

### check_links

**check_links** - gets the HTTP status code, or error message, for a given list of links

    Usage: check_links [FILE]... [options]
        -h, --help                       Display this screen
        -v, --verbose                    Verbose logging
        -t, --threads NUM                Threads to use

	where [FILE]… is a file (or list of files) containing a list of links to be checked (one link per line).

#### Examples

Check three links given in a file:

	$ cd lib
	$ cat ../examples/links 
	http://www.google.com.au
	http://www.facebook.com
	http://doesntexist.com.au
	$ ./check_links.rb ../examples/links
	"http://www.google.com","200"
	"http://www.facebook.com","301"
	"http://doesntexist.com.au","getaddrinfo: nodename nor servname provided, or not known"
	"","undefined method `request_uri' for #<URI::Generic:0x007fdea9d99c18 URL:>"

Take input (i.e. the links to check) from stdin:

	$ cd lib
	$ $ echo http://www.google.com.au | ./check_links.rb
	"http://www.google.com.au","200"

Pipe output of `cat_geoserver_links` to `check_links`, skipping email addresses and [coastalwatch](http://www.coastalwatch.com) addresses:

	$ cd lib
	$ ./cat_geoserver_links.rb http://geoserver.imos.org.au/geoserver | \
	egrep  -v "^mailto|http://www\.coastalwatch\.com" | \
	./check_links.rb

Speed up the above by using 10 threads:

	$ cd lib
	$ ./cat_geoserver_links.rb http://geoserver.imos.org.au/geoserver | \
	egrep  -v "^mailto|http://www\.coastalwatch\.com" | \
	./check_links.rb -t 10


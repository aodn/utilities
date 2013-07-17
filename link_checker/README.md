### Introduction

**check_links** - gets the HTTP status code, or error message, for a given list of links

    Usage: check_links [FILE]... [options]
        -h, --help                       Display this screen
        -v, --verbose                    Verbose logging
        -t, --threads NUM                Threads to use

	where [FILE]… is a file (or list of files) containing a list of links to be checked (one link per line).

### Examples

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

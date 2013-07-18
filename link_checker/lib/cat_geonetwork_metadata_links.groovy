import groovy.sql.Sql

@Grapes([
	@Grab('postgresql:postgresql:9.0-801.jdbc3'),
	@GrabConfig(systemClassLoader=true)
])

// Variables
FAILURE = -1
SUCCESS = 0

urlPattern = ~/https?:\\/\\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?/
recordCount = 0
foundUrls = [] as Set

// Load script arguments
if (argsValid()) {

	loadArguments()
}
else {

	printUsage()
	System.exit(FAILURE)
}

// Do the query
try {
	log "Connecting to: $connectionUrl"

	def sql = Sql.newInstance(
		connectionUrl,
		username,
		password,
		"org.postgresql.Driver"
	)

	sql.eachRow("SELECT id, data FROM metadata") {

		extractUrls(it, urlPattern)
	}
}
catch(Exception e) {

	writeErr "Unable to execute query on $connectionUrl"
	e.printStackTrace(System.err)
	System.exit(FAILURE)
}

// Write output
foundUrls.each{ write it }

log "$recordCount records searched"
log "${foundUrls.size()} unique URLs found"

System.exit(SUCCESS)

// Supporting logic

void loadArguments() {

	def safeArgs = args.toList() << "" // Ensure a 5th element for safe access

	// Load args from command line
	(host, database, username, password, debuggingEnabled) = safeArgs

	connectionUrl = "jdbc:postgresql://$host:5432/$database?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory"
}

def argsValid() {

	return args.length == 4 ||
           args.length == 5 && args.last() == "-v"
}

void printUsage() {

	writeErr "Please provide the database connection details. -v adds logging."
	writeErr "Usage: groovy .\\cat_geonetwork_metadata_links.groovy <host> <database_name> <username> <password> [-v]"
}

void extractUrls(record, pattern) {

	def matcher = pattern.matcher(record.data)

	def matchedUrls = matcher.collect{it.first()} // First result is whole URL

	debug "Record ${record.id} had ${matchedUrls.size()} matched URLs"

	recordCount++
	foundUrls.addAll matchedUrls
}

void write(s) {

	println s
}

void writeErr(s) {

	System.err.println s
}

void log(s) {

	writeErr s
}

void debug(s) {

	if (debuggingEnabled) writeErr s
}

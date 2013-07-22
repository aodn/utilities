@Grapes([
	@Grab('postgresql:postgresql:9.0-801.jdbc3'),
	@GrabConfig(systemClassLoader=true)
])

import groovy.sql.Sql

// Exit codes
FAILURE = 1
SUCCESS = 0

execute()

void execute() {

	// Load script arguments
	if (!argsValid()) {

		printUsage()
		System.exit(FAILURE)
	}

	loadArguments()
	initVariables()

	// Do the query
	try {
		log "Connecting to: $connectionUrl"

		def sql = Sql.newInstance(
			connectionUrl,
			username,
			password,
			"org.postgresql.Driver"
		)

		debug "Connection successful. Executing query."

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
}

def argsValid() {

	return args.length == 5 ||
           args.length == 6 && args.last() == "-v"
}

void printUsage() {

	writeErr "Please provide the database connection details. -v adds debug logging."
	writeErr "Usage: groovy .\\cat_geonetwork_metadata_links.groovy <host> <port> <database_name> <username> <password> [-v]"
}

void loadArguments() {

	def safeArgs = args.toList() << "" // Ensure a 6th element for safe access

	// Load args from command line
	(host, port, database, username, password, debuggingEnabled) = safeArgs	
}

void initVariables() {

	urlPattern = ~/https?:\\/\\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:\/~\+#]*[\w\-\@?^=%&\/~\+#])?/
	recordCount = 0
	foundUrls = [] as Set
	connectionUrl = "jdbc:postgresql://$host:$port/$database?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory"
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

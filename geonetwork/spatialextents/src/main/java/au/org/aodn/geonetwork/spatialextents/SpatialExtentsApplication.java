package au.org.aodn.geonetwork.spatialextents;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

import java.util.*;

@SpringBootApplication
public class SpatialExtentsApplication implements ApplicationRunner {

	@Autowired
	protected UpdateSpatialExtents updateSpatialExtents;

	@Value("${uuid:}")
	protected String uuid;

	@Value("${schema:}")
	protected String schema;

	@Value("${dbtable:}")
	protected String dbtable;

	@Value("${dbfield:}")
	protected String dbfield;

	@Value("${resolution:2}")
	protected String resolution;

	@Value("${printOnly:}")
	protected String printOnly;

	protected static Scanner scanner = new Scanner(System.in);

	protected static void printTable(Map<String, Object> values) {
		System.out.println("=================================================================");
		values
				.entrySet()
				.stream()
				.filter(i -> !i.getKey().contains("Pwd"))
				.forEach(action -> {
					System.out.format("%25s %40s", action.getKey(), action.getValue());
					System.out.println();
				});
		System.out.println("=================================================================");
	}

	protected static String question(String q, String defaultValue, Set<String> options) {
		String question = q;

		if(options != null && options.size() != 0) {
			question = question + " [" + String.join("|", options.toArray(new String[0])) + "]";
		}

		if(defaultValue != null) {
			question = question + " (default " + defaultValue + ")";
		}
		System.out.print(question + " ?");
		String ans = scanner.nextLine();

		if(options != null && !options.contains(ans)) {
			ans = defaultValue;
		}

		if(ans == null || ans.length() == 0) {
			ans = defaultValue;
		}
		return ans != null ? ans.trim() : null;
	}

	public static void main(String[] args) {
		Map<String, Object> values = new HashMap<>();

		values.put("env", question("GeoNetwork Environment", "local", new HashSet<>(Arrays.asList("rc","systest","prod"))));
		values.put("uuid", question("UUID of GeoNetwork record", null, null));
		values.put("schema", question("Schema name in harvest", null, null));
		values.put("dbtable", question("Table name in harvest", null, null));
		values.put("dbfield", question("Field name in harvest", "geom", null));
		values.put("resolution", question("Resolution for bound box", "2", null));
		values.put("printOnly", question("Output XML without update GeoNetwork", "y", new HashSet<>(Arrays.asList("y","n"))));
		values.put("havesterPwd", question("Password for Harvest DB", null, null));
		values.put("geonetworkPwd", question("Password for GeoNetwork", null, null));

		printTable(values);

		System.out.print("Proceed [y|n] ?");
		String a = scanner.nextLine();
		if("y".equalsIgnoreCase(a)) {
			SpringApplicationBuilder build = new SpringApplicationBuilder();

			build.profiles(values.get("env").toString())
					.properties(values)
					.sources(SpatialExtentsApplication.class)
					.main(SpatialExtentsApplication.class)
					.run(args);
		}
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {
		System.out.println("Depends on dataset, it may take few mins to run");
		updateSpatialExtents.update(
				uuid,
				schema,
				dbtable,
				dbfield,Integer.parseInt(resolution),
				!"n".equalsIgnoreCase(printOnly)
		);
	}
}

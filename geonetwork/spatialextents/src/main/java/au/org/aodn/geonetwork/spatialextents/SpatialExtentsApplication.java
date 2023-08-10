package au.org.aodn.geonetwork.spatialextents;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SpatialExtentsApplication implements ApplicationRunner {

	@Autowired
	protected UpdateSpatialExtents updateSpatialExtents;

	public static void main(String[] args) {
		SpringApplication.run(SpatialExtentsApplication.class, args);
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {
		if(args.getOptionNames().size() == 0) {
			System.out.println("Usage java -jar SpatialExtentsApplication.jar --uuid=x --schema=y --dbtable=z --resolution=1 --printOnly=[y|n]");
			System.out.println("uuid - The uuid found in geonetwork of the record to update");
			System.out.println("schema - The schema name in database harvest");
			System.out.println("dbtable - The table that hold the geom column to generate the bound box");
			System.out.println("dbfield - The field name that hold the bound box, default geom");
			System.out.println("resolution - The resolution for the bound box");
			System.out.println("printOnly - Show the XML on screen but not update geonetwork, good for debug");
		}
		else {
			System.out.println(String.format("PrintOnly = %s", args.getOptionValues("printOnly")));
			System.out.println("Depends on dataset, it may take few mins to run");
			updateSpatialExtents.update(
					args.getOptionValues("uuid").get(0),
					args.getOptionValues("schema").get(0),
					args.getOptionValues("dbtable").get(0),
					args.getOptionValues("dbfield") == null ? "geom" : args.getOptionValues("dbfield").get(0),
					Integer.parseInt(args.getOptionValues("resolution").get(0)),
					// Only explicit say "n" else always print only
					args.getOptionValues("printOnly") == null || !"n".equalsIgnoreCase(args.getOptionValues("printOnly").get(0))
			);
		}
	}
}

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
		updateSpatialExtents.update(
				args.getOptionValues("uuid").get(0),
				args.getOptionValues("schema").get(0),
				args.getOptionValues("dbtable").get(0),
				Integer.parseInt(args.getOptionValues("resolution").get(0))
		);
	}
}

package au.org.aodn.xslt;

import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.lib.FeatureKeys;
import org.apache.commons.cli.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.xml.transform.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class IndexCatalogue {
    private static final Logger logger = LogManager.getLogger(IndexCatalogue.class);
    public static void main(String[] args) throws TransformerException, IOException {
        System.out.println("INDEXER");

        CommandLine cmd = parseCommandLine(args);
        String catalogue = cmd.getOptionValue("c");
        File transform = new File(cmd.getOptionValue("t"));
        if (cmd.hasOption("u")) {
            String uuids  = cmd.getOptionValue("u");
        }

        // TODO: read in the uuids from text file or by GN search.

        // python ./get-uuids.py "$gn_addr/srv/eng/xml.search?fast=index&_isHarvested=$record_selection&from=1&to=2000" $gn_user_arg $gn_password_arg $gn_xsrftoken_arg


        //   https://stackoverflow.com/questions/11633134/how-to-process-remote-xml-files-with-xslt
        //   https://stackoverflow.com/questions/1667454/xsl-transformation-in-java-with-parameters
        // The xsl accesses the remote XML and creates JSON in memory

        System.out.println(transform);
        System.out.println(catalogue);

        Map<String, Object> parameters = new HashMap<>();
//        parameters.put("param1", param1);
        Source xslSource = new javax.xml.transform.stream.StreamSource(transform);

        // TODO: for each uuid transform the record.
        Source xmlSource = new javax.xml.transform.stream.StreamSource(getRecord(
        "https://catalogue.aodn.org.au/geonetwork/srv/api/records/a05f7892-ec0e-7506-e044-00144fdd4fa6/formatters/xml"
        ));
        StringWriter document = transform(xmlSource, xslSource, parameters);
        System.out.println(document);

        // TODO: POST _bulk or PUT to Opensearch instance



    }

    private static CommandLine parseCommandLine(String[] args) {

        Options options = new Options();
        options.addRequiredOption("c", "catalogue", true, "URL to the catalogue to be indexed.");
        options.addRequiredOption("t", "transform", true, "XSLT to apply which creates the payload for the index request.");
        options.addOption("u", "uuids", true, "Path to file containing list of UUIDS to index.");

        CommandLineParser parser = new DefaultParser();
        CommandLine cmd = null;

        String header = "Create search index from Geonetwork catalogue\n\n"+
                "If the -u option is provided then only the records listed in the file will be indexed. Otherwise " +
                "all records in the catalogue will be indexed";

        HelpFormatter formatter = new HelpFormatter();

        try {
            cmd = parser.parse(options, args);
        } catch (Exception e) {
            formatter.printHelp("indexCatalogue", header, options, null, true);
            System.exit(1);
        }

        return cmd;
    }

    private static StringWriter transform(Source xmlSource, Source xsltSource,
                                          Map<String, Object> parameters) throws TransformerException {
        StringWriter sw = new StringWriter();
        Result result = new javax.xml.transform.stream.StreamResult(sw);
        TransformerFactory transFact = new TransformerFactoryImpl();
        transFact.setAttribute(FeatureKeys.SUPPRESS_XPATH_WARNINGS, Boolean.TRUE);
        Transformer trans = transFact.newTransformer(xsltSource);
        for (Map.Entry<String, Object> parameter: parameters.entrySet()) {
            trans.setParameter(parameter.getKey(), parameter.getValue());
        }
        trans.transform(xmlSource, result);
        return sw;
    }

    private static InputStream getRecord(String urlString) throws IOException {

        URL url = new URL(urlString);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        return con.getInputStream();

    }
}

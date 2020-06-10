package au.org.aodn.xslt;

import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.lib.FeatureKeys;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import javax.xml.transform.*;
import java.io.*;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;

public class TransformCatalogue {

    private static final Logger logger = LogManager.getLogger(TransformCatalogue.class);

    public static void main(String[] args) {

        File from_19139_mcp_1_4_to_19139_mcp_2_0_xsl_file = new File("schema/iso19115-3/convert/ISO19139/to19139.mcp-2.0.xsl");
        File from_19139_mcp2_to_19115_3_xslFile = new File("schema/iso19115-3/convert/ISO19139/fromISO19139MCP2.xsl");
        File transform_19115_3_update_codeListLocation_xslFile = new File("schema/iso19115-3/process/update-codeListLocation.xsl");
        File substitute_urls_xslFile = new File("schema/iso19115-3/process/substitute-urls.xsl");

        Options options = new Options();
        options.addOption("d", "input_directory", true, "Directory name containing xml file name at some depth in the directory structure ");
        options.addRequiredOption("i", "file_name", true, "Input xml file name.");
        options.addRequiredOption("o", "output_file_name", true, "Output xml file name.");
        options.addRequiredOption("u", "url_substitutions", true, "Url substitutions configuration file");

        CommandLineParser parser = new DefaultParser();
        CommandLine cmd = null;

        String header = "Convert mcp xml file to 19115-3\n\n"+
                "If the -d option is specified then the directory will be recursively searched for any file with the " +
                "name specified by the -i option. The converted file will be created with the name specified by the " +
                "-o option at the same level in the directory structure as the input file. Specify the config file " +
                "containing target url and resource and metadata linkage " +
                "url replacements to be made during the transformation using the -u option.";

        HelpFormatter formatter = new HelpFormatter();

        try {
            cmd = parser.parse(options, args);
        } catch (Exception e) {
            formatter.printHelp("transformCatalogue", header, options, null, true);
            System.exit(1);
        }

        // Process input directory
        String inpath = null;
        File indirectory = null;
        if (cmd.hasOption("d")) {
            inpath = cmd.getOptionValue("d");
            indirectory = new File(inpath);
            if (!indirectory.exists()) {
                formatter.printHelp("transformCatalogue", header, options, null, true);
                System.exit(1);
            }
        }

        // Process input file name
        String input = cmd.getOptionValue("i");

        // Process output file name
        String output = cmd.getOptionValue("o");

        // Process transform config file
        String uArg = cmd.getOptionValue("u");
        String configFile = Paths.get(uArg).toAbsolutePath().toString();

        List<Path> files = new ArrayList<Path>();
        getFileNames(files, indirectory.toPath(), input);

        int count = 0;
        for (Path file : files) {
            try {
                count++;
                System.out.println("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
                logger.info("Transforming "+ count +  " of " + files.size());

                Source mcp1_4_xmlSource = new javax.xml.transform.stream.StreamSource(file.toFile());
                Source mcp2_xmlSource = mcp1_4_xmlSource;

                String namespaceURI = getNamespaceURI(mcp1_4_xmlSource);
                logger.info(namespaceURI);

                if(namespaceURI.equals("http://bluenet3.antcrc.utas.edu.au/mcp")) {

                    Source mcp1_4_xslSource = new javax.xml.transform.stream.StreamSource(from_19139_mcp_1_4_to_19139_mcp_2_0_xsl_file);

                    // Transform from_19139_mcp_1_4_to_19139_mcp_2_0
                    StringWriter sw_mcp1_4 = transform(mcp1_4_xmlSource, mcp1_4_xslSource);

                    // Outputs MCP2.0 records
                    write(file.getParent() + File.separator + "metadata.iso19139.mcp-2.0.xml", sw_mcp1_4);

                    mcp2_xmlSource = new javax.xml.transform.stream.StreamSource(new StringReader(sw_mcp1_4.toString()));
                }

                Source mcp2_xslSource = new javax.xml.transform.stream.StreamSource(from_19139_mcp2_to_19115_3_xslFile);

                // Transform parameters
                Map<String, Object> parameters = new HashMap<>();
                parameters.put("configFile", configFile);

                // Transform from_19139_mcp2_to_19115_3
                StringWriter sw_mcp2 = transform(mcp2_xmlSource, mcp2_xslSource, parameters);

                // Outputs ISO19115-3 records
                write(file.getParent() + File.separator + output, sw_mcp2);

                // Transform to update codelist location
                Source update_codeListLocation_xslSource = new javax.xml.transform.stream.StreamSource(transform_19115_3_update_codeListLocation_xslFile);
                Source sw_mcp1_xmlSource = new javax.xml.transform.stream.StreamSource(new StringReader(sw_mcp2.toString()));
                StringWriter updated_sw_mcp1 = transform(sw_mcp1_xmlSource, update_codeListLocation_xslSource);
                write(file.getParent() + File.separator + output, updated_sw_mcp1);

                // Perform the requested substitutions
                Source substitute_urls_xslSource = new javax.xml.transform.stream.StreamSource(substitute_urls_xslFile);
                Source sw_mcp2_xmlSource = new javax.xml.transform.stream.StreamSource(new StringReader(updated_sw_mcp1.toString()));
                StringWriter updated_sw_mcp2 = transform(sw_mcp2_xmlSource, substitute_urls_xslSource, parameters);
                write(file.getParent() + File.separator + output, updated_sw_mcp2);

            } catch( Exception e ) {
                e.printStackTrace();
            }

        } // for each path
    }

    private static String getNamespaceURI(Source source) throws XMLStreamException {
        XMLInputFactory inputFactory = XMLInputFactory.newInstance();
        XMLStreamReader reader = inputFactory.createXMLStreamReader(source);
        reader.nextTag();
        return reader.getNamespaceURI();
    }

    private static StringWriter transform(Source xmlSource, Source xsltSource) throws TransformerException {
        return transform(xmlSource, xsltSource, new HashMap<>());
    }

    private static StringWriter transform(Source xmlSource, Source xsltSource,
                                          Map<String, Object> parameters) throws TransformerException {
        StringWriter sw = new StringWriter();
        Result result = new javax.xml.transform.stream.StreamResult(sw);
        TransformerFactory transFact = new TransformerFactoryImpl();
        transFact.setAttribute(FeatureKeys.SUPPRESS_XPATH_WARNINGS, Boolean.TRUE);
        Transformer trans = transFact.newTransformer(xsltSource);
        for (Entry<String, Object> parameter: parameters.entrySet()) {
            trans.setParameter(parameter.getKey(), parameter.getValue());
        }
        trans.transform(xmlSource, result);
        return sw;
    }

    private static void write(String outfile, StringWriter sw) throws IOException {
        FileWriter out = new FileWriter(outfile);
        out.write(sw.toString());
        logger.info(outfile);
        out.close();
    }

    private static List<Path> getFileNames(List<Path> fileNames, Path dir, String infile) {
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir)) {
            for (Path path : stream) {
                if(path.toFile().isDirectory()) {
                    getFileNames(fileNames, path, infile);
                } else {
                    // only add filenames that match infile
                    boolean theTest = path.getFileName().toString().equals(infile);
                    if (theTest) {
                        //fileNames.add(path.toAbsolutePath().toString());
                        fileNames.add(path);
                    }
                }
            }
        } catch(IOException e) {
            e.printStackTrace();
        }
        return fileNames;
    }
}
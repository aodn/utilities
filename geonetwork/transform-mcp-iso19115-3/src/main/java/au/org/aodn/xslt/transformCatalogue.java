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
import java.util.ArrayList;
import java.util.List;

public class transformCatalogue {

    private static final Logger logger = LogManager.getLogger(transformCatalogue.class);

    public static void main(String[] args) throws TransformerException, IOException {

        File from_19139_mcp_1_4_to_19139_mcp_2_0_xsl_file = new File("schemas/iso19115-3/convert/ISO19139/to19139.mcp-2.0.xsl");
        File from_19139_mcp2_to_19115_3_xslFile = new File("schemas/iso19115-3/convert/ISO19139/fromISO19139MCP2.xsl");
        String inpath = "/tmp/gn-dump-local";
        String input = "metadata.xml";
        String output = "metadata.iso19115-3.2018.xml";
        File indirectory = new File(inpath);

        List<Path> files = new ArrayList<Path>();
        getFileNames(files, indirectory.toPath(), input);

        for (Path file : files) {
            try {
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

                // Transform from_19139_mcp2_to_19115_3
                StringWriter sw_mcp2 = transform(mcp2_xmlSource, mcp2_xslSource);

                // Outputs ISO19115-3 records
                write(file.getParent() + File.separator + output, sw_mcp2);

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

    private static StringWriter transform(Source xmlSource, Source xsltSource) throws IOException, TransformerException {
        StringWriter sw = new StringWriter();
        Result result = new javax.xml.transform.stream.StreamResult(sw);
        TransformerFactory transFact = new TransformerFactoryImpl();
        transFact.setAttribute(FeatureKeys.SUPPRESS_XPATH_WARNINGS, Boolean.TRUE);
        Transformer trans = transFact.newTransformer(xsltSource);
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

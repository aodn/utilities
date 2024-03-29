package au.org.aodn.xslt;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;

import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;
import static org.junit.Assert.assertEquals;

public class TransformCatalogueTest {

    private Path testDir;
    private Path resourceDir = Paths.get("src/test/resources");

    @Before
    public void setup() throws IOException {
        // Create test directory
        testDir = Files.createTempDirectory("export-");
    }

    @After
    public void tearDown() throws IOException {
        // Delete test directory
        deleteFolder(testDir);
    }

    @Test
    public void testContact() throws IOException {
        testFiles("contact");
    }

    @Test
    public void testDataParameters() throws IOException {
        testFiles("dataParameters");
    }

    @Test
    public void testDatasetUri() throws IOException {
        testFiles("datasetUri");
    }

    @Test
    public void testAggregationInfo() throws IOException {
        testFiles("aggregationInfo");
    }

    @Test
    public void testCredit() throws IOException {
        testFiles("credit");
    }

    @Test
    public void testDataQualityInfo() throws IOException {
        testFiles("dataQualityInfo");
    }

    @Test
    public void testDistributionInfo() throws IOException {
        testFiles("distributionInfo");
    }

    @Test
    public void testMetadataConstraints() throws IOException {
        testFiles("metadataConstraints");
    }

    @Test
    public void testCodeListLocation() throws IOException {
        testFiles("codelistlocation");
    }

    @Test
    public void testHierarchyLevel() throws IOException {
        testFiles("hierarchyLevel");
    }

    @Test
    public void testTemporalExtent() throws IOException {
        testFiles("temporalExtent");
    }

    @Test
    public void testPointOfContact() throws IOException {
        testFiles("pointOfContact");
    }

    @Test
    public void testMetadataLinkage() throws IOException {
        testFiles("metadataLinkage");
    }

    @Test
    public void testResourceConstraints() throws IOException {
        testFiles("resourceConstraints");
    }

    @Test
    public void testAcquisitionInformation() throws IOException {
        testFiles("acquisitionInformation");
    }

    @Test
    public void testOnlineResource() throws IOException {
        testFiles("onlineResource");
    }

    @Test
    public void testSamplingFrequency() throws IOException {
        testFiles("samplingFrequency");
    }

    @Test
    public void testMetadataContact() throws IOException {
        testFiles("metadataContact");
    }

    @Test
    public void testCitation() throws IOException {
        testFiles("citation");
    }

    @Test
    public void testDescriptiveKeywords() throws IOException {
        testFiles("descriptiveKeywords");
    }

    @Test
    public void testExtent() throws IOException {
        testFiles("extent");
    }

    @Test
    public void testMetadataMaintenance() throws IOException {
        testFiles("metadataMaintenance");
    }

    @Test
    public void testResourceFormat() throws IOException {
        testFiles("resourceFormat");
    }

    @Test
    public void testResourceMaintenance() throws IOException {
        testFiles("resourceMaintenance");
    }

    @Test
    public void testSpatialRepresentationType() throws IOException {
        testFiles("spatialRepresentationType");
    }

    @Test
    public void testSpatialResolution() throws IOException {
        testFiles("spatialResolution");
    }

    @Test
    public void testEnvironmentDescription() throws IOException {
        testFiles("environmentDescription");
    }


    @Test
    public void codeListValue() throws IOException {
        testFiles("codelistvalue");
    }

    @Test
    public void testProdSubstitutions() throws IOException {
        testFiles("prodSubstitutions", "url-substitutions/imos-prod.xml");
    }

    private void testFiles(String testSubDirName) throws IOException {
        testFiles(testSubDirName, "url-substitutions/imos-test.xml");
    }

    private void testFiles(String testSubDirName, String urlSubstitutionsFile) throws IOException {
        Path resourceSubDir = resourceDir.resolve(testSubDirName + "/export");
        // Copy test files to test directory
        copyFolder(resourceSubDir, testDir);

        // Run transform
        String args[] = {
                "TransformCatalogue",
                "-d", testDir.toString(),
                "-i", "metadata.xml",
                "-o", "metadata.iso19115-3.2018.xml",
                "-u", urlSubstitutionsFile
        };
        TransformCatalogue.main(args);
        // Assert each test result matches expected result
        for (File testCaseDir: testDir.toFile().listFiles(File::isDirectory)) {
            String testCaseName = testCaseDir.getName();
            Path expectedFile = resourceDir.resolve(testSubDirName + "/expected").resolve(testCaseName + ".xml");
            Path actualFile = testCaseDir.toPath().resolve("metadata/metadata.iso19115-3.2018.xml");
            String expectedResult = new String(Files.readAllBytes(expectedFile));
            String actualResult = new String(Files.readAllBytes(actualFile));
            assertEquals(expectedResult, actualResult);
        }
    }
    private void deleteFolder(Path pathToBeDeleted) throws IOException {
        Files.walk(pathToBeDeleted)
            .sorted(Comparator.reverseOrder())
            .map(Path::toFile)
            .forEach(File::delete);
    }

    private void copyFolder(Path src, Path dest) throws IOException {
        Files.walk(src)
            .forEach(source -> copy(source, dest.resolve(src.relativize(source))));
    }

    private void copy(Path source, Path dest) {
        try {
            Files.copy(source, dest, REPLACE_EXISTING);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }
}

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
    public void testResourceConstraints() throws IOException {
        testFiles("resourceConstraints");
    }

    @Test
    public void testAllMetadataTags() throws IOException {
        // Copy test files to test directory
        copyFolder(resourceDir.resolve("export"), testDir);

        // Run transform
        String args[] = {
            "TransformCatalogue",
            "-d", testDir.toString(),
            "-i", "metadata.xml",
            "-o", "metadata.iso19115-3.2018.xml",
            "-g", "http://catalogue-imos.dev.aodn.org.au/geonetwork",
            "-u"
        };
        TransformCatalogue.main(args);

        // Assert each test result matches expected result
        for (File testCaseDir: testDir.toFile().listFiles(File::isDirectory)) {
            String testCaseName = testCaseDir.getName();
            Path expectedFile = resourceDir.resolve("expected").resolve(testCaseName + ".xml");
            Path actualFile = testCaseDir.toPath().resolve("metadata/metadata.iso19115-3.2018.xml");
            String expectedResult = new String(Files.readAllBytes(expectedFile));
            String actualResult = new String(Files.readAllBytes(actualFile));
            assertEquals(expectedResult, actualResult);
        }
    }

    private void testFiles(String testSubDirName) throws IOException {
        Path resourceSubDir = resourceDir.resolve(testSubDirName + "/export");
        // Copy test files to test directory
        copyFolder(resourceSubDir, testDir);

        // Run transform
        String args[] = {
                "TransformCatalogue",
                "-d", testDir.toString(),
                "-i", "metadata.xml",
                "-o", "metadata.iso19115-3.2018.xml",
                "-g", "http://catalogue-imos.dev.aodn.org.au/geonetwork",
                "-u"
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
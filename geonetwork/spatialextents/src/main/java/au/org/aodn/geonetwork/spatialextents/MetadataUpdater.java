package au.org.aodn.geonetwork.spatialextents;

import org.jdom.Namespace;
import java.util.List;

/**
 * Geonetwork metadata updater, allows you to fetch a metadata record, change
 * the XML and commit it back
 *
 * @author danfruehauf
 */
class MetadataUpdater {

    public void removeNodes(org.jdom.Document document, List<Namespace> namespaces, String parentXPath, String elementName, org.jdom.Namespace namespace) throws Exception {
        org.jdom.xpath.XPath xpath = org.jdom.xpath.XPath.newInstance(parentXPath);
        addNamespaces(xpath, namespaces);
        org.jdom.Element parentElement = (org.jdom.Element)xpath.selectSingleNode(document);

        if (parentElement != null) {
            parentElement.removeChildren(elementName, namespace);
        } else {
            System.out.println(parentXPath + " could not be found in xml document");
        }
    }

    public void addNode(org.jdom.Document document, List<org.jdom.Namespace> namespaces, String parentXPath, org.jdom.Element element) throws Exception {
        org.jdom.xpath.XPath xpath = org.jdom.xpath.XPath.newInstance(parentXPath);
        addNamespaces(xpath, namespaces);
        org.jdom.Element parentElement = (org.jdom.Element)xpath.selectSingleNode(document);

        if (parentElement != null) {
            parentElement.addContent(0, element);
        } else {
            System.err.println(parentXPath + " could not be found in xml document");
        }
    }

    public void addNodes(org.jdom.Document document, List<org.jdom.Namespace> namespaces, String parentXPath, List<org.jdom.Element> elements) throws Exception {
        for (org.jdom.Element element : elements) {
            addNode(document, namespaces, parentXPath, element);
        }
    }

    private void addNamespaces(org.jdom.xpath.XPath xPath, List<org.jdom.Namespace> namespaces) {
        for (org.jdom.Namespace namespace : namespaces) {
            xPath.addNamespace(namespace);
        }
    }
}
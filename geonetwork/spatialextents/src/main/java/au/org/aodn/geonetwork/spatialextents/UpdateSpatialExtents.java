package au.org.aodn.geonetwork.spatialextents;

import it.geosolutions.geonetwork.GNClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class UpdateSpatialExtents {

    @Autowired
    private GNClient geonetworkClient;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /*
        Translate the following code to the code in update(), this code copy from Talend
            try {

            String boundingPolygon_<%=cid%> = null;

            java.sql.Connection conn_<%=cid%> = null;
            java.sql.Statement stmt_<%=cid %> = null;
            java.sql.ResultSet rs_<%=cid %> = null;

        );

            try {
            <%
                if(("true").equals(useExistingConn)) {
                    String conn = "conn_" + connection; %>
                    conn_<%=cid%> = (java.sql.Connection)globalMap.get("<%=conn%>");
            <% } else { %>
                    java.lang.Class.forName("org.postgresql.Driver");
                    String url_<%=cid %> = "jdbc:postgresql://"+<%=dbhost%>+":"+<%=dbport%>+"/"+<%=dbname%>;
                    String dbUser_<%=cid %> = <%=dbuser%>;
                    String dbPwd_<%=cid %> = <%=dbpwd%>;
                    conn_<%=cid%> = java.sql.DriverManager.getConnection(url_<%=cid %>, dbUser_<%=cid%>, dbPwd_<%=cid%>);
            <% } %>

                // Get bounding polygon from postgres (requires BoundingPolygonAsGml3 function to be installed)

                String query = "select BoundingPolygonAsGml3('" + <%=dbschema%> + "','" + <%=dbtable%> + "','" + <%=dbcol%> + "'," + <%=resolution%> + ")";
                stmt_<%=cid %> = conn_<%=cid %>.createStatement();
                rs_<%=cid %> = stmt_<%=cid %>.executeQuery(query);
                rs_<%=cid %>.next();
                boundingPolygon_<%=cid%> = rs_<%=cid %>.getString("BoundingPolygonAsGml3");
            } finally {
                if (rs_<%=cid %> != null) rs_<%=cid %>.close();
                if (stmt_<%=cid %> != null) stmt_<%=cid %>.close();

            <%    if(("false").equals(useExistingConn)) { %>
                    if (conn_<%=cid%> != null) conn_<%=cid%>.close();
            <% } %>
            }

            // Connect to Geonetwork

            System.out.format( "* iUpdateSpatialExtent - creating geonetwork client\n");
            it.geosolutions.geonetwork.GNClient geonetworkClient_<%= cid %> = new it.geosolutions.geonetwork.GNClient(
                    <%= gnServiceUrl %>,
          <%= gnUsername %>,
          <%= gnPassword %>
        );

            // Fetch specified metadata record

            System.out.format( "* iUpdateSpatialExtent - getting metadata record: %s\n", <%= uuid %>);
            org.jdom.Document metadata_<%= cid %> = new org.jdom.Document(
                    geonetworkClient_<%= cid %>.get(<%= uuid %>)
        );

            org.jdom.Namespace gmdNs = org.jdom.Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd");
            org.jdom.Namespace gcoNs = org.jdom.Namespace.getNamespace("gco", "http://www.isotc211.org/2005/gco");
            org.jdom.Namespace gmlNs = org.jdom.Namespace.getNamespace("gml", "http://www.opengis.net/gml");

            if(metadata_<%= cid %>.getRootElement().getNamespace().getURI().equals("http://standards.iso.org/iso/19115/-3/mdb/2.0")) {
                gmdNs = org.jdom.Namespace.getNamespace("gex", "http://standards.iso.org/iso/19115/-3/gex/1.0");
                gcoNs = org.jdom.Namespace.getNamespace("gco", "http://standards.iso.org/iso/19115/-3/gco/1.0");
                gmlNs = org.jdom.Namespace.getNamespace("gml", "http://www.opengis.net/gml/3.2");
            }

            List<org.jdom.Element> geographicElements_<%=cid%> = new java.util.ArrayList<org.jdom.Element>();

            if (boundingPolygon_<%=cid%> == null) {
                org.jdom.Element geographicElement = new org.jdom.Element("geographicElement", gmdNs)
                        .setAttribute("nilReason", "inapplicable", gcoNs);
                geographicElements_<%=cid%>.add(geographicElement);
            } else {
                // Turn it into an XML document (Postgis doesn't include the gml namespace declaration in the returned xml
                // so we add a root element containing the required declaration)

                StringBuilder postgisWrapper_<%=cid%> = new StringBuilder("<postgisResult xmlns:gml=\"");
                postgisWrapper_<%=cid%>.append(gmlNs.getURI());
                postgisWrapper_<%=cid%>.append("\">");
                postgisWrapper_<%=cid%>.append(boundingPolygon_<%=cid%>);
                postgisWrapper_<%=cid%>.append("</postgisResult>");
                String wrappedGml_<%=cid%> = postgisWrapper_<%=cid%>.toString();

                org.jdom.input.SAXBuilder saxBuilder_<%=cid%> = new org.jdom.input.SAXBuilder();
                org.jdom.Document doc_<%=cid%> = saxBuilder_<%=cid%>.build(new java.io.StringReader(wrappedGml_<%=cid%>));

                // Get srsName for use in creating gmd:polygon's

                org.jdom.xpath.XPath srsElementXpath_<%=cid%> = org.jdom.xpath.XPath.newInstance("//*[@srsName]");
                org.jdom.Element srsNameElement_<%=cid%> = (org.jdom.Element) srsElementXpath_<%=cid%>.selectSingleNode(doc_<%=cid%>);
                String srsName_<%=cid%> = srsNameElement_<%=cid%>.getAttributeValue("srsName");

                // Convert included polygons into a list of iso19115/iso19139 gmd:geographicElements

                org.jdom.xpath.XPath xpath_<%=cid%> = org.jdom.xpath.XPath.newInstance("//gml:Polygon");
                xpath_<%=cid%>.addNamespace(gmlNs);
                List<org.jdom.Element> polygons_<%=cid%> = (List<org.jdom.Element>) xpath_<%=cid%>.selectNodes(doc_<%=cid%>);

                for (org.jdom.Element polygon : polygons_<%=cid%>) {
                    polygon.setAttribute("srsName", srsName_<%=cid%>);
                    org.jdom.Element polygonElement = new org.jdom.Element("polygon", gmdNs);
                    if(metadata_<%= cid %>.getRootElement().getNamespace().getURI().equals("http://standards.iso.org/iso/19115/-3/mdb/2.0")) {
                        org.jdom.Element surfaceMemberElement = new org.jdom.Element("surfaceMember", gmlNs).addContent((org.jdom.Element) polygon.clone());
                        org.jdom.Element multiSurfaceElement = new org.jdom.Element("MultiSurface", gmlNs).addContent(surfaceMemberElement);
                        multiSurfaceElement.setAttribute("srsName", srsName_<%=cid%>);
                        polygonElement.addContent(multiSurfaceElement);
                    }
                else {
                        polygonElement.addContent((org.jdom.Element) polygon.clone());
                    }
                    org.jdom.Element exBoundingPolygonElement = new org.jdom.Element("EX_BoundingPolygon", gmdNs).addContent(polygonElement);
                    org.jdom.Element geographicElement = new org.jdom.Element("geographicElement", gmdNs).addContent(exBoundingPolygonElement);
                    geographicElements_<%=cid%>.add(geographicElement);
                }
            }

            // Update metadata record

            MetadataUpdater metadataUpdater = new MetadataUpdater();

            List<org.jdom.Namespace> namespaces_<%= cid %> = new java.util.ArrayList<org.jdom.Namespace>();
            namespaces_<%= cid %>.add(gmdNs);

            metadataUpdater.removeNodes(metadata_<%= cid %>, namespaces_<%= cid %>, "//"+gmdNs.getPrefix()+":EX_Extent", "geographicElement", gmdNs);
            metadataUpdater.addNodes(metadata_<%= cid %>,  namespaces_<%= cid %>, "//"+gmdNs.getPrefix()+":EX_Extent", geographicElements_<%=cid%>);

            // Post updated record back to Geonetwork

            System.out.format( "* iUpdateSpatialExtent - updating metadata: %s\n", <%= uuid %>);
            geonetworkClient_<%= cid %>.updateMetadata(<%= uuid %>, metadata_<%= cid %>.getRootElement());

        } catch (Exception e) {
            System.out.format( "* iUpdateSpatialExtent - ERROR UPDATING SPATIAL EXTENT: cid=%s jobName=%s harvestType=%s uuid=%s exception=%s \n", "<%= cid %>", <%= jobName %>, <%= harvestType %>, <%= uuid %>, e.getMessage());
            System.out.format( "* iUpdateSpatialExtent - stack trace to follow");
            e.printStackTrace();
        }
     */
    public void update(String uuid, String schema, String dbtable, int resolution) throws Exception {
        String boundingPolygon = null;
        // * iUpdateSpatialExtent - updating uuid '35234913-aa3c-48ec-b9a4-77f822f66ef8' from soop_xbt_nrt.soop_xbt_nrt_profiles_map.geom using 2 degree resolution
        //
        // System.out.format(
        //         "* iUpdateSpatialExtent - updating uuid '%s' from %s.%s.%s using %s degree resolution\n",
        //         <%= uuid %>, <%=dbschema%>, <%=dbtable%>, <%=dbcol%>, <%=resolution%>
        String dbCol = "geom";

        String query = String.format(
                "select BoundingPolygonAsGml3('%s','%s','%s',%d)",
                schema,
                dbtable,
                dbCol,
                resolution
        );
        
        List<String> result = jdbcTemplate.query(query, (rs, rowNum) -> rs.getString(1));
        if(result.size() != 1) {
            throw new DataRetrievalFailureException("Must return 1 item after BoundingPolygonsAsGml3 call");
        }
        else {
            boundingPolygon = result.get(0);
        }
        org.jdom.Document metadata = new org.jdom.Document(geonetworkClient.get(uuid));

        org.jdom.Namespace gmdNs = org.jdom.Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd");
        org.jdom.Namespace gcoNs = org.jdom.Namespace.getNamespace("gco", "http://www.isotc211.org/2005/gco");
        org.jdom.Namespace gmlNs = org.jdom.Namespace.getNamespace("gml", "http://www.opengis.net/gml");

        if(metadata.getRootElement().getNamespace().getURI().equals("http://standards.iso.org/iso/19115/-3/mdb/2.0")) {
            gmdNs = org.jdom.Namespace.getNamespace("gex", "http://standards.iso.org/iso/19115/-3/gex/1.0");
            gcoNs = org.jdom.Namespace.getNamespace("gco", "http://standards.iso.org/iso/19115/-3/gco/1.0");
            gmlNs = org.jdom.Namespace.getNamespace("gml", "http://www.opengis.net/gml/3.2");
        }

        List<org.jdom.Element> geographicElements = new java.util.ArrayList<>();

        if (boundingPolygon == null) {
            org.jdom.Element geographicElement = new org.jdom.Element("geographicElement", gmdNs)
                    .setAttribute("nilReason", "inapplicable", gcoNs);
            geographicElements.add(geographicElement);
        } else {
            // Turn it into an XML document (Postgis doesn't include the gml namespace declaration in the returned xml
            // so we add a root element containing the required declaration)

            StringBuilder postgisWrapper = new StringBuilder("<postgisResult xmlns:gml=\"");
            postgisWrapper.append(gmlNs.getURI());
            postgisWrapper.append("\">");
            postgisWrapper.append(boundingPolygon);
            postgisWrapper.append("</postgisResult>");
            String wrappedGml = postgisWrapper.toString();

            org.jdom.input.SAXBuilder saxBuilder = new org.jdom.input.SAXBuilder();
            org.jdom.Document doc = saxBuilder.build(new java.io.StringReader(wrappedGml));

            // Get srsName for use in creating gmd:polygon's

            org.jdom.xpath.XPath srsElementXpath = org.jdom.xpath.XPath.newInstance("//*[@srsName]");
            org.jdom.Element srsNameElement = (org.jdom.Element) srsElementXpath.selectSingleNode(doc);
            String srsName = srsNameElement.getAttributeValue("srsName");

            // Convert included polygons into a list of iso19115/iso19139 gmd:geographicElements

            org.jdom.xpath.XPath xpath = org.jdom.xpath.XPath.newInstance("//gml:Polygon");
            xpath.addNamespace(gmlNs);
            List<org.jdom.Element> polygons = (List<org.jdom.Element>) xpath.selectNodes(doc);

            for (org.jdom.Element polygon : polygons) {
                polygon.setAttribute("srsName", srsName);
                org.jdom.Element polygonElement = new org.jdom.Element("polygon", gmdNs);
                if(metadata.getRootElement().getNamespace().getURI().equals("http://standards.iso.org/iso/19115/-3/mdb/2.0")) {
                    org.jdom.Element surfaceMemberElement = new org.jdom.Element("surfaceMember", gmlNs).addContent((org.jdom.Element) polygon.clone());
                    org.jdom.Element multiSurfaceElement = new org.jdom.Element("MultiSurface", gmlNs).addContent(surfaceMemberElement);
                    multiSurfaceElement.setAttribute("srsName", srsName);
                    polygonElement.addContent(multiSurfaceElement);
                }
                else {
                    polygonElement.addContent((org.jdom.Element) polygon.clone());
                }
                org.jdom.Element exBoundingPolygonElement = new org.jdom.Element("EX_BoundingPolygon", gmdNs).addContent(polygonElement);
                org.jdom.Element geographicElement = new org.jdom.Element("geographicElement", gmdNs).addContent(exBoundingPolygonElement);
                geographicElements.add(geographicElement);
            }

            // Update metadata record

            MetadataUpdater metadataUpdater = new MetadataUpdater();

            List<org.jdom.Namespace> namespaces = new java.util.ArrayList<>();
            namespaces.add(gmdNs);

            metadataUpdater.removeNodes(metadata, namespaces, "//"+gmdNs.getPrefix()+":EX_Extent", "geographicElement", gmdNs);
            metadataUpdater.addNodes(metadata,  namespaces, "//"+gmdNs.getPrefix()+":EX_Extent", geographicElements);

            // Post updated record back to Geonetwork

            System.out.format( "* iUpdateSpatialExtent - updating metadata: %s\n", uuid);
            geonetworkClient.updateMetadata(uuid, metadata.getRootElement());
        }
    }
}
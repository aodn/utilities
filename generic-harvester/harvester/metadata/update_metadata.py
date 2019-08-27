"""
Extent Metadata Updater (Spatial, Temporal, Vertical)
"""

import xml.etree.ElementTree as ElementTree
from harvester.metadata.geonetworklib import Geonetwork, GeonetworkRecord
from harvester.database.database_store_dao import DatabaseStoreDao

import uuid
import json
from io import StringIO

NS_GML = 'http://www.opengis.net/gml'
NS_GMD = 'http://www.isotc211.org/2005/gmd'
NS_GCO = 'http://www.isotc211.org/2005/gco'
NS_MCP = 'http://schemas.aodn.org.au/mcp-2.0'


class MetadataUpdater(object):

    def __init__(self, config):

        self.db_params = config["db_params"]
        self.metadata_params = config["metadata_params"]
        self.metadata_updates = config["metadata_updates"]
        self.url = '{}://{}:{}@{}:{}/{}'.format(self.db_params["driver"],
                                                self.db_params["user"],
                                                self.db_params["password"],
                                                self.db_params["host"],
                                                self.db_params["port"],
                                                self.db_params["database"]
                                                )
        self.geonetwork = self.get_geonetwork()

    def get_geonetwork(self):
        """
        Creates geonetwork instance
        :return: geonetwork instance
        """

        return Geonetwork(self.metadata_params["url"],
                          username=self.metadata_params["username"],
                          password=self.metadata_params["password"])

    @staticmethod
    def register_namespace(xml_text):
        """
        Registers a namespace prefix
        :param xml_text: xml content
        :return:
        """
        my_namespaces = dict([
            node for (_, node) in ElementTree.iterparse(StringIO(xml_text), events=['start-ns'])
        ])
        for prefix, uri in my_namespaces.items():
            ElementTree.register_namespace(prefix, uri)

    @staticmethod
    def get_extent(record, name):
        """
        Get temporal extent
        :param record: a GeonetworkRecord instance
        :param name: name of extent element in a GeonetworkRecord
        :return: specified extent element
        """
        return ElementTree.fromstring(record.xml_text).findall('.//'
                                                               '{' + NS_GMD + '}extent/'
                                                               '{' + NS_GMD + '}EX_Extent/'+name)

    def set_extent(self, record, name, value):
        """
        Set vertical extent (maximum and minimum) value
        :param record: a GeonetworkRecord instance
        :param name: name of extent element in a GeonetworkRecord
        :param value: value of extent element in a GeonetworkRecord
        :return: an updated GeonetworkRecord instance
        """
        xml_text = record.xml_text
        self.register_namespace(xml_text)
        root = ElementTree.fromstring(xml_text)
        _ex_extent = root.find('.//'
                               '{' + NS_GMD + '}extent/'
                               '{' + NS_GMD + '}EX_Extent')

        for element in _ex_extent.findall(name):
            _ex_extent.remove(element)

        for element in ElementTree.fromstring(value):
            _ex_extent.append(element)

        xml_text = ElementTree.tostring(root, encoding='unicode')
        return GeonetworkRecord(xml_text=xml_text, uuid=uuid)

    def load_spatial_extent(self, metadata_update):
        """
        Load spatial extent from database
        :param metadata_update: metadata update parameter
        :return: spatial extent xml elements
        """
        query = "select BoundingPolygonAsGml3('{}','{}','{}',{})".format(self.db_params["schema"],
                                                                         metadata_update["spatial_table"],
                                                                         metadata_update["spatial_column"],
                                                                         metadata_update["spatial_resolution"]
                                                                         )

        polygons = None
        dao = DatabaseStoreDao(self.url)
        rs = list(dao.select_query(query))

        for results in rs:
            for result in list(results):
                polygons = result

        query_result = "<postgisResult " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:gml=\"{}\">".format(NS_GMD, NS_GML)
        if polygons is not None:
            query_result += "<gmd:geographicElement>" \
                            "<gmd:EX_BoundingPolygon>" \
                            "<gmd:polygon>{}</gmd:polygon>" \
                            "</gmd:EX_BoundingPolygon>" \
                            "</gmd:geographicElement>".format(polygons)
        query_result += "</postgisResult>"

        return query_result

    def load_temporal_extent(self, metadata_update):
        """
        Load temporal extent from database
        :param metadata_update: metadata update parameter
        :return: temporal extent xml elements
        """

        query = "SELECT timezone('UTC'::text, MIN(\"{}\")) as min_value, " \
                "timezone('UTC'::text, MAX(\"{}\")) as max_value " \
                "FROM {}.{}".format(metadata_update["temporal_column"],
                                    metadata_update["temporal_column"],
                                    self.db_params["schema"],
                                    metadata_update["temporal_table"]
                                    )

        gml_id = uuid.uuid4().hex
        begin_time = None
        end_time = None

        dao = DatabaseStoreDao(self.url)
        rs = dao.select_query(query)
        for results in rs:
            begin_time = results["min_value"]
            end_time = results["max_value"]

        query_result = "<postgisResult " \
                       "xmlns:gml=\"{}\" " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:mcp=\"{}\" " \
                       "xmlns:gco=\"{}\" >".format(NS_GML, NS_GMD, NS_MCP, NS_GCO)
        if begin_time is not None and end_time is not None:
            query_result += "<gmd:temporalElement>" \
                            "<mcp:EX_TemporalExtent gco:isoType=\"gmd:EX_TemporalExtent\">" \
                            "<gmd:extent>" \
                            "<gml:TimePeriod gml:id =\"{}\">".format(gml_id)
            if begin_time is not None:
                query_result += "<gml:begin>" \
                                "<gml:TimeInstant gml:id = \"{}\">" \
                                "<gml:timePosition>{}</gml:timePosition>" \
                                "</gml:TimeInstant>" \
                                "</gml:begin>".format(gml_id, begin_time)
            if end_time is not None:
                query_result += "<gml:end>" \
                                "<gml:TimeInstant gml:id = \"{}\">" \
                                "<gml:timePosition>{}</gml:timePosition>" \
                                "</gml:TimeInstant>" \
                                "</gml:end>".format(gml_id, end_time)
            query_result += "</gml:TimePeriod>" \
                            "</gmd:extent>" \
                            "</mcp:EX_TemporalExtent>" \
                            "</gmd:temporalElement>"
            query_result += "</postgisResult>"

        return query_result

    def load_vertical_extent(self, metadata_update):
        """
        Load vertical extent from database
        :param metadata_update: metadata update parameter
        :return: vertical extent xml elements
        """

        query_min = "SELECT MIN({}::real) as min_value FROM {}.{} fm " \
                    "JOIN {}.{} ga ON (fm.{} = ga.{}) " \
                    "WHERE {} = '{}'".format(metadata_update["vertical_column_value"],
                                             self.db_params["schema"],
                                             metadata_update["vertical_file_metadata_table"],
                                             metadata_update["vertical_index_schema"],
                                             metadata_update["vertical_index_table"],
                                             metadata_update["vertical_file_metadata_table_column"],
                                             metadata_update["vertical_index_table_column"],
                                             metadata_update["vertical_column_name"],
                                             metadata_update["vertical_column_name_min"]
                                             )

        query_max = "SELECT MAX({}::real) as max_value FROM {}.{} fm " \
                    "JOIN {}.{} ga ON (fm.{} = ga.{}) " \
                    "WHERE {} = '{}'".format(metadata_update["vertical_column_value"],
                                             self.db_params["schema"],
                                             metadata_update["vertical_file_metadata_table"],
                                             metadata_update["vertical_index_schema"],
                                             metadata_update["vertical_index_table"],
                                             metadata_update["vertical_file_metadata_table_column"],
                                             metadata_update["vertical_index_table_column"],
                                             metadata_update["vertical_column_name"],
                                             metadata_update["vertical_column_name_max"]
                                             )

        min_value = None
        max_value = None

        dao = DatabaseStoreDao(self.url)
        rs = dao.select_query(query_min)
        for results in rs:
            min_value = results["min_value"]

        rs = dao.select_query(query_max)
        for results in rs:
            max_value = results["max_value"]

        query_result = "<postgisResult " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:gco=\"{}\">".format(NS_GMD, NS_GCO)
        if min_value is not None and max_value is not None:
            query_result += "<gmd:verticalElement>" \
                            "<gmd:EX_VerticalExtent>"

            if min_value is not None:
                query_result += "<gmd:minimumValue>"\
                                "<gco:Real>{}</gco:Real>" \
                                "</gmd:minimumValue>".format(min_value)

            if max_value is not None:
                query_result += "<gmd:maximumValue>" \
                      "<gco:Real>{}</gco:Real>" \
                      "</gmd:maximumValue>".format(max_value)

            query_result += "</gmd:EX_VerticalExtent>" \
                            "</gmd:verticalElement>"
        query_result += "</postgisResult>"

        return query_result

    def update_metadata(self, spatial=False, temporal=False, vertical=False):
        """
        Updates metadata information (spatial extent, temporal extent, vertical extent)
        :param spatial: Boolean to update spatial extent. Default is False
        :param temporal: Boolean to update temporal extent. Default is False
        :param vertical: Boolean to update vertical extent. Default is False
        :return:
        """
        for metadata_update in self.metadata_updates:
            _uuid = metadata_update["uuid"]
            _id = self.geonetwork.get_id_from_uuid(_uuid)
            version = 0
            record = self.geonetwork.record(_uuid)

            if spatial:
                record = self.set_extent(record,
                                         '{' + NS_GMD + '}geographicElement',
                                         self.load_spatial_extent(metadata_update))
            if temporal:
                record = self.set_extent(record,
                                         '{' + NS_GMD + '}temporalElement',
                                         self.load_temporal_extent(metadata_update))
            if vertical:
                record = self.set_extent(record,
                                         '{' + NS_GMD + '}verticalElement',
                                         self.load_vertical_extent(metadata_update))

            self.geonetwork.update_record(_id, version, record)


if __name__ == '__main__':

    with open("../../config/abos_sofs_fl.json") as f:
        _config = json.load(f)

    # Create MetadataUpdater instance
    updater = MetadataUpdater(_config)

    # Update metadata information
    updater.update_metadata(True, True, True)

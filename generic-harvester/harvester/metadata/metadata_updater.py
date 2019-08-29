"""

Extent Metadata Updater (Spatial, Temporal, Vertical)

"""

import xml.etree.ElementTree as ElementTree
from harvester.metadata.geonetworklib import Geonetwork, GeonetworkRecord
from harvester.store.database_store import DatabaseStore
from io import StringIO

import uuid
import random
import string
import json


NS_GML = 'http://www.opengis.net/gml'
NS_GMD = 'http://www.isotc211.org/2005/gmd'
NS_GCO = 'http://www.isotc211.org/2005/gco'


class MetadataUpdater(object):

    def __init__(self, metadata_store, config, logger):
        """
        Create a new MetadataUpdater

        :param metadata_store: metadata store to write harvested information to or delete from
        :param config: metadata updater config
        :param logger: logger for messages
        """

        self.metadata_store = metadata_store
        self.db_params = config["db_params"]
        self.geonetwork_params = config["geonetwork_params"]
        self.metadata_updates = config["metadata_updates"]
        self.logger = logger
        self.geonetwork = self.create_geonetwork()

    def create_geonetwork(self):
        """
        Creates geonetwork instance
        :return: geonetwork instance
        """

        return Geonetwork(self.geonetwork_params["url"],
                          username=self.geonetwork_params["username"],
                          password=self.geonetwork_params["password"])

    @staticmethod
    def generate_id():
        """
        Generates 20 digits unique id starting with non-numeric character
        :return: unique 20 digits id
        """
        return random.choice(string.ascii_lowercase) + str(uuid.uuid4().hex)

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
        query = "SELECT BoundingPolygonAsGml3('{}','{}','{}',{})".format(self.db_params["schema"],
                                                                         metadata_update["table"],
                                                                         metadata_update["column"],
                                                                         metadata_update["resolution"]
                                                                         )

        polygons = None
        rs = self.metadata_store.select_query(query)

        for results in rs:
            for result in list(results):
                polygons = result

        query_result = "<spatialResult " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:gml=\"{}\">".format(NS_GMD, NS_GML)
        if polygons is not None:
            query_result += "<gmd:geographicElement>" \
                            "<gmd:EX_BoundingPolygon>" \
                            "<gmd:polygon>{}</gmd:polygon>" \
                            "</gmd:EX_BoundingPolygon>" \
                            "</gmd:geographicElement>".format(polygons)
        query_result += "</spatialResult>"

        return query_result

    def load_temporal_extent(self, metadata_update):
        """
        Load temporal extent from database
        :param metadata_update: metadata update parameter
        :return: temporal extent xml elements
        """

        begin_time = None
        end_time = None

        if metadata_update:
            query = "SELECT TO_CHAR(timezone('UTC'::text, MIN(\"{}\")), 'YYYY-MM-DDThh:mm:ss') as min_value, " \
                    "TO_CHAR(timezone('UTC'::text, MAX(\"{}\")), 'YYYY-MM-DDThh:mm:ss') as max_value " \
                    "FROM {}.{}".format(metadata_update["column"],
                                        metadata_update["column"],
                                        self.db_params["schema"],
                                        metadata_update["table"])

            rs = self.metadata_store.select_query(query)
            for results in rs:
                begin_time = results["min_value"]
                end_time = results["max_value"]

        query_result = "<temporalResult " \
                       "xmlns:gml=\"{}\" " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:gco=\"{}\">".format(NS_GML, NS_GMD, NS_GCO)
        if begin_time is not None and end_time is not None:
            query_result += "<gmd:temporalElement>" \
                            "<gmd:EX_TemporalExtent>" \
                            "<gmd:extent>" \
                            "<gml:TimePeriod gml:id =\"{}\">".format(self.generate_id())
            if begin_time is not None:
                query_result += "<gml:begin>" \
                                "<gml:TimeInstant gml:id = \"{}\">" \
                                "<gml:timePosition>{}</gml:timePosition>" \
                                "</gml:TimeInstant>" \
                                "</gml:begin>".format(self.generate_id(), begin_time)
            if end_time is not None:
                query_result += "<gml:end>" \
                                "<gml:TimeInstant gml:id = \"{}\">" \
                                "<gml:timePosition>{}</gml:timePosition>" \
                                "</gml:TimeInstant>" \
                                "</gml:end>".format(self.generate_id(), end_time)
            query_result += "</gml:TimePeriod>" \
                            "</gmd:extent>" \
                            "</gmd:EX_TemporalExtent>" \
                            "</gmd:temporalElement>"
        query_result += "</temporalResult>"

        return query_result

    def load_vertical_extent(self, metadata_update):
        """
        Load vertical extent from database
        :param metadata_update: metadata update parameter
        :return: vertical extent xml elements
        """

        query = "SELECT " \
                "MIN(\"{}\") as \"min_value\"," \
                "MAX(\"{}\") as \"max_value\" " \
                "FROM {} as result".format(metadata_update["min_column"],
                                           metadata_update["max_column"],
                                           ''.join(metadata_update["relation"]))

        min_value = None
        max_value = None

        rs = self.metadata_store.select_query(query)
        for results in rs:
            min_value = results["min_value"]
            max_value = results["max_value"]

        query_result = "<verticalResult " \
                       "xmlns:gmd=\"{}\" " \
                       "xmlns:gco=\"{}\">".format(NS_GMD, NS_GCO)
        if min_value is not None or max_value is not None:
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

            query_result += "<gmd:verticalCRS gco:nilReason=\"missing\"/>" \
                            "</gmd:EX_VerticalExtent>" \
                            "</gmd:verticalElement>"
        query_result += "</verticalResult>"
        return query_result

    def update_metadata(self):
        """
        Updates metadata information (spatial extent, temporal extent, vertical extent)
        :return:
        """
        for metadata_update in self.metadata_updates:

            spatial = metadata_update.get("spatial", None)
            temporal = metadata_update.get("temporal", None)
            vertical = metadata_update.get("vertical", None)

            if spatial is not None or temporal is not None or vertical is not None:

                _uuid = metadata_update["uuid"]
                _id = self.geonetwork.get_id_from_uuid(_uuid)
                version = 0
                record = self.geonetwork.record(_uuid)

                if spatial is not None:
                    record = self.set_extent(record,
                                             '{' + NS_GMD + '}geographicElement',
                                             self.load_spatial_extent(spatial))
                if temporal is not None:
                    record = self.set_extent(record,
                                             '{' + NS_GMD + '}temporalElement',
                                             self.load_temporal_extent(temporal))
                if vertical is not None:
                    record = self.set_extent(record,
                                             '{' + NS_GMD + '}verticalElement',
                                             self.load_vertical_extent(vertical))

                self.geonetwork.update_record(_id, version, record)

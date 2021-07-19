"""
Geonetwork Library
"""

import xml.etree.ElementTree as ElementTree
from collections import namedtuple

import requests

ENDPOINT_CONN_CHECK = '/srv/eng/xml.info?type=site'

ENDPOINT_RECORD_VERSION = '/srv/eng/xml.metadata.version?uuid='
ENDPOINT_RECORD_SEARCH = '/srv/eng/xml.search.imos'
ENDPOINT_RECORD_GET = '/srv/eng/xml.metadata.get?uuid='
ENDPOINT_RECORD_INSERT = '/srv/eng/xml.metadata.insert'
ENDPOINT_RECORD_UPDATE = 'srv/eng/xml.metadata.update'
ENDPOINT_RECORD_DELETE = '/srv/eng/metadata.delete?uuid='
ENDPOINT_RECORD_ADMIN = '/srv/eng/metadata.admin'

record_fields = ['xml_text', 'uuid']
record_compare_fields = ['uuid']


class GeonetworkRecord(namedtuple('GeonetworkRecord', record_fields)):
    __slots__ = ()

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.comparisontuple == other.comparisontuple

    def __ne__(self, other):
        return not self.__eq__(other)

    @property
    def comparisontuple(self):
        return tuple(getattr(self, attr) for attr in record_compare_fields)

    @classmethod
    def from_dict(cls, d):
        return cls(**d)

    @classmethod
    def from_xml_file(cls, uuid, path):
        with open(path) as f:
            xml_text = f.read()
        return cls(uuid=uuid, xml_text=xml_text)

class GeonetworkHTTPError(Exception):
    def __init__(self, status_code, message, error_class=None, inner_exception=None):
        self.message = message
        self.status_code = status_code
        self.error_class = error_class
        self.inner_exception = inner_exception

    def __repr__(self):
        return "{}(message='{}', status_code='{}', error_class='{}', inner_exception='{}')".format(
            self.__class__.__name__, self.message, self.status_code, self.error_class, self.inner_exception)

    __str__ = __repr__

    @classmethod
    def from_httperror(cls, e):
        """Construct exception from a given HTTPError instance, and extract Geonetwork specific error details if
        available

        :param e: HTTPError instance
        :return: constructed GeonetworkHTTPError instance
        """
        try:
            tree = ElementTree.fromstring(e.response.content)
        except ElementTree.ParseError:
            message = e.message
            error_class = None
        else:
            error_class = tree.findtext('class')
            xml_message = tree.findtext('message')
            message = "{e.message}: {xml_message}".format(e=e, xml_message=xml_message)

        return cls(message=message, status_code=e.response.status_code, error_class=error_class, inner_exception=e)


class Geonetwork(object):
    def __init__(self, base_url, username=None, password=None):
        self.base_url = base_url

        self.session = requests.Session()
        if username and password:
            self.session.auth = (username, password)
        self.session.headers.update({'Accept': 'application/xml'})

        # initial connectivity check
        _ = self._post(ENDPOINT_CONN_CHECK)

    def _get(self, path):
        url = "{}{}".format(self.base_url, path)
        response = self.session.get(url)
        try:
            response.raise_for_status()
        except requests.HTTPError as e:
            raise GeonetworkHTTPError.from_httperror(e)
        return response

    def _post(self, path, data=None, files=None, headers=None):
        url = "{}{}".format(self.base_url, path)
        response = self.session.post(url, data=data, files=files, headers=headers)
        try:
            response.raise_for_status()
        except requests.HTTPError as e:
            raise GeonetworkHTTPError.from_httperror(e)
        return response

    @property
    def records(self):
        """List of existing Geonetwork records
        :return: set containing a GeonetworkRecord instance representing each existing record"""
        response = self._get(ENDPOINT_RECORD_SEARCH)
        # print(response.content)
        # uuids = ElementTree.fromstring(response.content).findall('.//uuid')

        return {GeonetworkRecord(xml_text=self._get('{}{}'.format(ENDPOINT_RECORD_GET, uuid.text)).text, uuid=uuid.text)
                for uuid in ElementTree.fromstring(response.content).findall('.//uuid')}

    def record(self, uuid):
        """List Geonetwork record with specified uuid
        :return: a GeonetworkRecord instance representing specified record"""
        return GeonetworkRecord(xml_text=self._get('{}{}'.format(ENDPOINT_RECORD_GET, uuid)).text, uuid=uuid)

    def update_record(self, _id, version, record):
        """
        Update Geonetwork record
        :param _id: Geonetwork record ID
        :param version: Geonetwork record version
        :param record: Geonetwork record
        :return:
        """
        if not isinstance(record, GeonetworkRecord):
            raise TypeError('argument must be a GeonetworkRecord instance')
        data = {'id': _id,
                'version': version,
                'data': record.xml_text,
                }
        self._post(ENDPOINT_RECORD_UPDATE, data=data)

    def get_id_from_uuid(self, uuid):
        """
        Get ID of Geonetwork record with specified UUID
        :param uuid: UUID of a Geonetwork record
        :return: ID of a Geonetwork record with specified UUID
        """
        response = self._get('{}{}'.format(ENDPOINT_RECORD_VERSION, uuid))
        return ElementTree.fromstring(response.content).find('.//id').text

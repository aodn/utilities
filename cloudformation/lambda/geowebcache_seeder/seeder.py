import urllib
import urllib2
from xml.etree.cElementTree import ElementTree

from log import SeederBaseObject


class GeoWebCache:
    def __init__(self, url, username, password):
        self.url = url
        self.username = username
        self.password = password

    def get_seed_url(self):
        return "{url}/rest/seed".format(url=self.url)

    def get_seed_layer_url(self, layer):
        return "{url}/rest/seed/{layer}".format(url=self.url, layer=layer)

    def get_seed_layer_xml_url(self, layer):
        return "{url}/rest/seed/{layer}.xml".format(url=self.url, layer=layer)

    def get_truncate_url(self):
        return "{url}/rest/masstruncate".format(url=self.url)


class GeoNetworkConnector(SeederBaseObject):
    GEONETWORK_SEARCH_REQUEST = "/srv/eng/xml.search.summary?sortBy=popularity&from=1&to=999&fast=index"

    def __init__(self, geonetwork_url):
        super(GeoNetworkConnector, self).__init__()
        self.geonetwork_url = geonetwork_url + GeoNetworkConnector.GEONETWORK_SEARCH_REQUEST

    def get_wms_layers(self):
        layers = []
        tree = ElementTree(file=urllib2.urlopen(self.geonetwork_url))

        for metadata in tree.iter('metadata'):
            geonetwork_metadata_links = GeonetworkMetadataLinks(metadata)
            wms_link = geonetwork_metadata_links.get_wms_link()

            if 'layer' in wms_link and 'server' in wms_link:
                self.log("Probed layer {layer} from Geonetwork {server}".format(**wms_link))
                layers.append(wms_link)

        return layers


class GeonetworkMetadataLinks:
    def __init__(self, xml_metadata):
        self.xml_metadata = xml_metadata
        self.links = []

        for xml_link in self.xml_metadata.iter('link'):
            self.links.append(xml_link.text)

    def get_wms_link(self):
        wms_link = {}
        for link in self.links:
            layer, data_collection, server, protocol, req_format = link.split("|")
            if protocol.startswith('OGC:WMS-') and protocol.endswith('http-get-map'):
                wms_link = {'server': server, 'layer': layer}
                break

        return wms_link


class Seeder(SeederBaseObject):
    def __init__(self, geowebcache):
        super(Seeder, self).__init__()
        self.geowebcache = geowebcache

    def truncate_layer(self, layer):
        self.log("Truncating layer {layer}".format(layer=layer))
        options = ("<truncateLayer>"
                   "<layerName>{layer}</layerName>"
                   "</truncateLayer>").format(layer=layer)

        headers = [('Content-type', 'application/xml')]
        self.geowebcache_request(self.geowebcache.get_truncate_url(), options, headers)

    def purge_layer(self, layer):
        self.log("Purging layer {layer}".format(layer=layer))
        data = urllib.urlencode({'kill_all': 'all'})
        self.geowebcache_request(self.geowebcache.get_seed_layer_url(layer), data)

    def seed_layer(self, layer, grid_set_id, start_zoom, end_zoom, req_format, req_type, thread_count):
        self.log("Seeding layer {layer}".format(layer=layer))
        options = ("<seedRequest>"
                   "<name>{layer}</name>"
                   "<gridSetId>{grid_set_id}</gridSetId>"
                   "<zoomStart>{start_zoom}</zoomStart>"
                   "<zoomStop>{end_zoom}</zoomStop>"
                   "<format>{req_format}</format>"
                   "<type>{req_type}</type>"
                   "<threadCount>{thread_count}</threadCount>"
                   "</seedRequest>").format(layer=layer, grid_set_id=grid_set_id,
                                            start_zoom=start_zoom, end_zoom=end_zoom,
                                            req_format=req_format, req_type=req_type,
                                            thread_count=str(thread_count))
        headers = [('Content-type', 'application/xml')]
        self.geowebcache_request(self.geowebcache.get_seed_layer_xml_url(layer), options, headers)

    def geowebcache_request(self, geowebcache_url, data, headers=()):
        try:
            pass_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
            pass_mgr.add_password(None, geowebcache_url, self.geowebcache.username, self.geowebcache.password)
            auth_handler = urllib2.HTTPBasicAuthHandler(pass_mgr)
            # Enable to debug http requests and pass the http_handler to build_opener
            # http_handler = urllib2.HTTPHandler(debuglevel=1)
            opener = urllib2.build_opener(auth_handler)
            opener.addheaders = headers
            urllib2.install_opener(opener)
            urllib2.urlopen(url=geowebcache_url, data=data).read()
        except urllib2.HTTPError as e:
            self.log_exception(e)
            return e

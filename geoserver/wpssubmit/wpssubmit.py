#!/usr/bin/env python

import argparse
import datetime
import httplib
import logging.config
import os
import re
import ssl
import sys
import time
import urllib
import urlparse
import xml.etree.ElementTree as ElementTree

LOG_FORMAT = '%(asctime)s - %(levelname)s - %(message)s'
logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)
LOGGER = logging.getLogger(__name__)


class WpsJob(object):
    def __init__(self, submit_data, host, path, port, https, noverifycerts):
        self.submit_data = submit_data
        self.host = host
        self.path = path
        self.port = port
        self.https = https
        self.noverifycerts = noverifycerts

        self._status_re = re.compile(r'^{http://www.opengis.net/wps/1.0.0}(\w+)$')
        self.status_url = None

    def _make_request(self, url, method='GET', body=None, headers=None):
        conn_kwargs = {'host': self.host}
        if self.https:
            conn_class = httplib.HTTPSConnection
            if self.noverifycerts:
                conn_kwargs['context'] = ssl._create_unverified_context()
            conn_kwargs['port'] = self.port if self.port else '443'
        else:
            conn_class = httplib.HTTPConnection
            conn_kwargs['port'] = self.port if self.port else '80'
        connection = conn_class(**conn_kwargs)

        request_kwargs = dict()
        if body:
            request_kwargs['body'] = body
        if headers:
            request_kwargs['headers'] = headers
        connection.request(method, url, **request_kwargs)

        response = connection.getresponse()
        return ElementTree.fromstring(response.read())

    def submit(self):
        headers = {'Content-Type': 'application/xml', 'Connection': 'keep-alive'}
        root = self._make_request(self.path, method='POST', body=self.submit_data, headers=headers)
        LOGGER.info('Response:{nl}{root}'.format(nl=os.linesep, root=ElementTree.tostring(root)))
        self.status_url = urlparse.urlparse(root.attrib['statusLocation'])

    def get_status(self):
        url = "{path}?{query}".format(path=self.status_url.path, query=self.status_url.query)
        root = self._make_request(url)
        match_status = self._status_re.match(root[1][0].tag)
        status = match_status.group(1)
        LOGGER.info("Status poll: {status}".format(status=status))
        return status


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--infile', required=True, help='WPS XML input file')
    parser.add_argument('-I', '--interval', default=5, help='Poll interval for status checks')
    parser.add_argument('-H', '--host', default='geoserver-rc.aodn.org.au', help='Geoserver host name')
    parser.add_argument('-p', '--path', default='/geoserver/wps', help='Geoserver web service path')
    parser.add_argument('-P', '--port', help='Geoserver HTTP(s) port')
    parser.add_argument('-e', '--https', action="store_true", help='Connect to Geoserver using HTTPS')
    parser.add_argument('-c', '--noverifycerts', action='store_true', help='Accept invalid certificates (HTTPS)')
    args = parser.parse_args()

    reader = urllib.urlopen if re.match(r'^https?://.*$', args.infile) else open
    try:
        submit_data = reader(args.infile).read()
    except Exception as e:
        LOGGER.exception('failed to read input file')
        sys.exit(1)
    finally:
        if hasattr(reader, 'close'):
            reader.close()

    job = WpsJob(submit_data, host=args.host, path=args.path, port=args.port, https=args.https,
                 noverifycerts=args.noverifycerts)
    LOGGER.info(
        "Submitting WPS job XML {infile} to {host}{path}".format(infile=args.infile, host=args.host, path=args.path))
    job.submit()
    LOGGER.info("Status URL: {url}".format(url=urlparse.urlunparse(job.status_url)))

    status = None
    while status in (None, 'ProcessAccepted', 'ProcessStarted'):
        status = job.get_status()
        if status == 'ProcessFailed':
            LOGGER.error('Job failed')
            sys.exit(2)
        elif status == 'ProcessSucceeded':
            LOGGER.info('Job completed successfully!')
        else:
            time.sleep(args.interval)


if __name__ == '__main__':
    main()

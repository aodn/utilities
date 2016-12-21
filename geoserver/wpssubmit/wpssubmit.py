import argparse
import datetime
import httplib
import os
import re
import ssl
import sys
import time
import urlparse
import xml.etree.ElementTree as ElementTree


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
            conn_kwargs['port'] = self.port and self.port or '443'
        else:
            conn_class = httplib.HTTPConnection
            conn_kwargs['port'] = self.port and self.port or '80'
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
        self.status_url = urlparse.urlparse(root.attrib['statusLocation'])

    def get_status(self):
        url = "{path}?{query}".format(path=self.status_url.path, query=self.status_url.query)
        root = self._make_request(url)
        match_status = self._status_re.match(root[1][0].tag)
        status = match_status.group(1)
        print("{now} Status poll: {status}".format(now=datetime.datetime.now(), status=status))
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

    if not os.path.exists(args.infile):
        parser.print_help()
        sys.exit(1)

    with open(args.infile, 'r') as f:
        submit_data = f.read()
    job = WpsJob(submit_data, host=args.host, path=args.path, port=args.port, https=args.https,
                 noverifycerts=args.noverifycerts)
    print("Submitting WPS job XML {infile} to {host}{path}".format(infile=args.infile, host=args.host, path=args.path))
    job.submit()
    print("Status URL: {url}".format(url=urlparse.urlunparse(job.status_url)))

    status = 'Initial'
    while status in ('Initial', 'ProcessAccepted', 'ProcessStarted'):
        status = job.get_status()
        if status == 'ProcessFailed':
            print('Job failed')
            sys.exit(2)
        elif status == 'ProcessSucceeded':
            print('Job completed successfully!')
        else:
            time.sleep(args.interval)


if __name__ == '__main__':
    main()

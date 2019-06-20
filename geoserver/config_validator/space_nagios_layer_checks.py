import argparse
import time
from datetime import datetime

import requests

from validate_geoserver_config import load_layers


def get_layer_check_groups(host, layers, group_size=5):
    checks = []
    for layer in layers:
        protocol = 'wms' if layer.name.endswith('_map') else 'wfs'
        post_data = dict(
            cmd_typ=7,
            cmd_mod=2,
            host=host,
            service="geoserver {protocol}:{layer.workspace}:{layer.name}".format(protocol=protocol, layer=layer),
            start_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            force_check='1')
        checks.append(post_data)

    return [checks[x:x + group_size] for x in range(0, len(checks), group_size)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--host', required=True)
    parser.add_argument('-c', '--geoserver-config-path', required=True)
    parser.add_argument('-u', '--username', required=True)
    parser.add_argument('-p', '--password', required=True)
    parser.add_argument('-n', '--nagios-url', required=True)
    parser.add_argument('-t', '--sleep-time', type=int, default=5)
    parser.add_argument('-g', '--check-group-size', type=int, default=5)
    args = parser.parse_args()

    layers = load_layers(args.geoserver_config_path)
    print("splitting checks into groups of {}".format(args.check_group_size))
    check_groups = get_layer_check_groups(args.host, layers, group_size=args.check_group_size)

    s = requests.Session()
    s.auth = (args.username, args.password)

    for group in check_groups:
        for check in group:
            print("running check {check}".format(check=check))
            try:
                r = s.post(args.nagios_url, data=check)
                r.raise_for_status()
            except Exception:
                print('failed check, proceeding to the next check...')
        print("sleeping for {} seconds between check group".format(args.sleep_time))
        time.sleep(args.sleep_time)


if __name__ == '__main__':
    main()

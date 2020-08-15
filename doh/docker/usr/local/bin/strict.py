#!/usr/bin/python3 -u
from socket import AF_INET, AF_INET6
from time import asctime
import pyroute2

def list_routes():
    ret = []

    iproute = pyroute2.IPRoute()
    for route in iproute.get_routes():
        # Route Family
        family = ''
        if route['family'] == AF_INET:
            family = 'AF_INET'
        elif route['family'] == AF_INET6:
            family = 'AF_INET6'
        else:
            continue

        r = {
            'class': family,
            'tablenum': int(route['table']),
            'cidr': int(route['dst_len'])
        }

        # Route Attribs
        for attr, value in route['attrs']:
            if attr == 'RTA_PRIORITY':
                r['prio'] = int(value)
            elif attr == 'RTA_GATEWAY':
                r['gateway'] = str(value)
            elif attr == 'RTA_DST':
                r['dst'] = str(value)
            elif attr == 'RTA_PREFSRC':
                r['prefsrc'] = str(value)
            elif attr == 'RTA_OIF':
                r['oif'] = int(value)

        # Detect default gateway record
        if 'gateway' in r.keys() and not 'dst' in r.keys() and route['dst_len'] == 0:
            if route['family'] == AF_INET:
                r['dst'] = '0.0.0.0'
            elif route['family'] == AF_INET6:
                r['dst'] = '::'

        ret.append(r)
    return ret

def del_route(route):
    iproute = pyroute2.IPRoute()
    kwargs = {}

    for arg in list(route.keys()):
        if arg in ['prefsrc', 'dst', 'gateway', 'oif']:
            kwargs[arg] = route[arg]

    if 'tablenum' in list(route.keys()):
        kwargs['table'] = route['tablenum']

    if 'oif' in list(route.keys()):
        kwargs['dst'] = '{}/{}'.format(kwargs['dst'], route['cidr'])
    else:
        if 'cidr' in list(route.keys()):
            kwargs['dst_len'] = route['cidr']

    if 'prio' in list(route.keys()):
        kwargs['attrs'] = [
            ('RTA_PRIORITY', route['prio'])
        ]

    iproute.route('del', **kwargs)

def log(msg):
    print('[{}]: {}'.format(asctime(), msg))

if __name__ == "__main__":
    for route in list_routes():
        if route['tablenum'] == 254 and route['cidr'] == 0:
            log("Removing default gateway...")
            del_route(route)

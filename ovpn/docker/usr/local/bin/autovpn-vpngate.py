#!/usr/bin/python3 -u
import os, sys, shutil, io
import json, csv
import base64
import requests
from Crypto import Random
import argparse

__csv_list_source = 'https://www.vpngate.net/api/iphone/'

# def log(msg):
#     print(msg, file=sys.stderr)

def build_config(vpn):
    lines = []
    for (key, value) in vpn['config'].items():
        if value.find('\n') < 0:
            lines.append('{} {}'.format(key, value))
        else:
            lines.append('<{}>'.format(key))
            lines.append(value)
            lines.append('</{}>'.format(key))
    return '\n'.join(lines)

def parse_config(raw):
    params = {}

    # Filter for comments
    without_comments = []
    for line in raw.splitlines():
        if len(line) == 0:
            continue
        if line[0] == '#' or line[0] == ';':
            continue
        without_comments.append(line)

    # Read config
    multiline_mode = False
    multiline_buffer = ""
    multiline_param = ""
    for line in without_comments:
        if multiline_mode:
            if line.find('</{}>'.format(multiline_param)) >= 0:
                params[multiline_param] = multiline_buffer[:-1]
                multiline_mode = False
                multiline_buffer = ""
                multiline_param = ""
            else:
                multiline_buffer += line + '\n'
        else:
            param = line.split(' ')[0]
            if (param.find('<') >= 0) and (param.find('<') < param.find('>')):
                multiline_mode = True
                multiline_param = param[param.find('<')+1:param.find('>')]
            else:
                params[param] = ' '.join(line.split(' ')[1:])

    # Filter for alowed options
    for (key, value) in list(params.items()):
        if not key in ['dev', 'proto', 'remote', 'cipher', 'auth', 'nobind', 'persist-key', 'persist-tun', 'client', 'ca', 'key', 'cert', 'verb', 'tls-auth']:
            del params[key]
            params[';{}'.format(key)] = value

    return params

def acquire_vpn_list():
    ret = []
    for entity in acquire_vpn_list_raw():
        config = parse_config(base64.decodebytes(entity['config'].encode('utf-8')).decode('utf-8'))
        entity['config'] = config
        ret.append(entity)
    return ret

def acquire_vpn_list_raw():
    ret = []
    try:
        response = requests.get(__csv_list_source)
    except HTTPError as e:
        raise e
    except Exception as e:
        raise e
    if response.status_code != 200:
        raise Exception('Failed to acquire VPN servers list: non-200 responce code')
    csvfile = io.StringIO(response.text)
    for row in csv.reader(csvfile, delimiter=','):
        if len(row) < 15:
            continue
        if len(row[0]) < 1:
            continue
        if row[0][0] == '#':
            continue
        entity = {
            'endpoint': row[1],
            'score': int(row[2]),
            'uptime': int(row[8]),
            'country': row[6].upper(),
            'sessions': int(row[7]),
            'owner': row[12].replace("'s owner", ""),
            'config': row[14],
        }
        ret.append(entity)
    return ret

def filter_vpn_list(vpns, uptime_min=None, score_min=None, score_max=None, country=None, proto=None):
    if uptime_min != None:
        vpns = filter_vpn_list_lambda(vpns, lambda vpn: vpn['uptime'] > uptime_min)
    if score_min != None:
        vpns = filter_vpn_list_lambda(vpns, lambda vpn: vpn['score'] > score_min)
    if score_max != None:
        vpns = filter_vpn_list_lambda(vpns, lambda vpn: vpn['score'] < score_max)
    if country != None:
        ret = []
        for c in country.split(','):
            ret = ret + filter_vpn_list_lambda(vpns, lambda vpn: vpn['country'] == c.upper())
        vpns = ret
    if proto != None:
        vpns = filter_vpn_list_lambda(vpns, lambda vpn: vpn['config']['proto'].lower() == proto.lower())
    return vpns

def filter_vpn_list_lambda(vpns, func):
    ret = []
    for vpn in vpns:
        if func(vpn):
            ret.append(vpn)
    return ret

def select_random(vpns):
    return vpns[int.from_bytes(Random.get_random_bytes(4), byteorder='little') % len(vpns)]

def main():
    argparse_prog = 'autovpn.py'
    argparse_description  = 'Command line tool which return OpenVPN configuration file from free public VPN servers\n'
    argparse_description += 'list. VPNGate Project used for acquire configuration(s).\n\n'
    argparse_epilog =  'Examples:\n'
    argparse_epilog += '  {}                        # Return just any available random VPN server\n'.format(argparse_prog)
    argparse_epilog += '  {} -c EN                  # Return one of british VPN server\n'.format(argparse_prog)
    argparse_epilog += '  {} -c EN,US               # Return british or american VPN server (but only one!)\n'.format(argparse_prog)
    argparse_epilog += '  {} -smin 300000 -u 172800 # Return one of server with 300k+ score and 2+ days uptime\n'.format(argparse_prog)
    parser = argparse.ArgumentParser(prog=argparse_prog, description=argparse_description, epilog=argparse_epilog, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-c', '--country', dest='country', nargs='?', type=str, help='Filter: comma-separated list of alowed country codes')
    parser.add_argument('-smin', '--score-min', dest='score_min', nargs='?', type=str, help='Filter: minimal score to use')
    parser.add_argument('-smax', '--score-max', dest='score_max', nargs='?', type=str, help='Filter: maximal score to use')
    parser.add_argument('-u', '--uptime', dest='uptime', nargs='?', type=str, help='Filter: minimal uptime to use')
    parser.add_argument('-p', '--proto', dest='proto', nargs='?', type=str, help='Filter: alowed connection protocol to use: tcp or udp')

    parser.add_argument('--json', dest='json', action='store_true', help='Return JSON output with selected server configuration and metadata. This cannot be use as config for any vpn client. Helpful for debug')
    parser.add_argument('--all', dest='all', action='store_true', help='Return JSON list of ALL founded servers. Alowed only with "--json" option. This cannot be use as config for any vpn client. Helpful for debug')
    args = parser.parse_args()

    # print(json.dumps(select_random(acquire_vpn_list())))

    # Acquire
    vpns = acquire_vpn_list()

    # Filter
    vpns = filter_vpn_list(vpns, uptime_min=args.uptime, score_min=args.score_min, score_max=args.score_max, country=args.country, proto=args.proto)

    # args.json = True
    if args.json:
        if args.all:
            json.dump(vpns, fp=sys.stdout)
        else:
            json.dump(select_random(vpns), fp=sys.stdout)
    else:
        print(build_config(select_random(vpns)))

if __name__ == "__main__":
    main()

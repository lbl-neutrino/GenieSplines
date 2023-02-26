#!/usr/bin/env python3

import argparse
from pathlib import Path


FLAVORS = [14, -14, 12, -12, 16, -16]

# get these from the max path file
NUCLEI = [1000050110, 1000060120, 1000070140, 1000080160, 1000110230,
          1000120240, 1000130270, 1000140280, 1000150310, 1000160320,
          1000170350, 1000180400, 1000190390, 1000200400, 1000220480,
          1000240520, 1000250550, 1000260560, 1000280590, 1000300640,
          1000822070]

NUCLEONS = [1000000010, 1000010010 ]


def what_do_we_have(direc='splines/nuclei'):
    have = set()

    for xmlpath in Path(direc).glob('*.xml'):
        parts = xmlpath.name.split('_')
        flavor, target = int(parts[4]), int(parts[5])
        assert flavor in FLAVORS and target in TARGETS
        have.add((flavor, target))

    return have


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mode', choices=['nucleons', 'nuclei'], required=True)
    ap.add_argument('--filter-from', help='Directory of existing splines to skip')
    args = ap.parse_args()

    targets = NUCLEONS if args.mode == 'nucleons' else NUCLEI
    jobs = {(flavor, target) for flavor in FLAVORS for target in targets}

    if args.filter_from:
        jobs -= what_do_we_have(args.filter_from)

    for flavor, target in sorted(jobs):
        print(f'{flavor} {target}')


if __name__ == '__main__':
    main()

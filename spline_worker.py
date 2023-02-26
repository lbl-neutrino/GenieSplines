#!/usr/bin/env python3

import argparse
from subprocess import call
import sys

from zeroworker import LockfileListReader, LockfileListWriter

sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)


def run_gmkspl(outdir, flavor, target, xsec):
    cmd = f'./run_gmkspl.sh {outdir} {flavor} {target} {xsec}'
    call(cmd, shell=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i', '--input', required=True)
    ap.add_argument('-o', '--outdir', required=True)
    ap.add_argument('--xsec', default='')
    args = ap.parse_args()

    reader = LockfileListReader(args.input)
    logger = LockfileListWriter(args.input + '.done')

    with logger:
        for line in reader:
            parts = line.strip().split()
            flavor, target = map(int, parts)
            run_gmkspl(args.outdir, flavor, target, args.xsec)
            logger.log(f'{flavor} {target}')


if __name__ == '__main__':
    main()

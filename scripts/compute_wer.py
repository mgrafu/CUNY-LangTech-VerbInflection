#!/usr/bin/env python
"""Computes WER from a fairseq generate output predictions file."""

import argparse
import contextlib
import csv
import logging


def group_predictions(sourcepath: str, goodpath: str, badpath: str) -> float:
    total = 0
    incorrect = 0
    with contextlib.ExitStack() as stack:
        source = open(sourcepath, "r")
        goodsink = csv.writer(stack.enter_context(open(goodpath, 'w')), delimiter='\t')
        badsink = csv.writer(stack.enter_context(open(badpath, 'w')), delimiter='\t')

        for line in source:
            line = line.rstrip()
            if line.startswith("T"):
                _, t = line.split("\t")
                total += 1
            if line.startswith("D"):
                _, _, d = line.split("\t")
                
                t = "".join(t.split())
                d = "".join(d.split())
                
                if t == d:
                    goodsink.writerow([t, d])
                else:
                    incorrect += 1
                    badsink.writerow([t, d])
                    
    return incorrect / total


def main(args: argparse.Namespace) -> None:
    wer = group_predictions(args.sourcepath, args.goodpath, args.badpath)
    logging.info(f"WER:\t{wer:.2%}")
    print(wer)

if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(levelname)s: %(message)s")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "sourcepath",
        type=str,
        help="path to predictions text file",
    )
    parser.add_argument(
        "goodpath",
        type=str,
        help="path to write good predictions text file",
    )
    parser.add_argument(
        "badpath",
        type=str,
        help="path to write bad predictions text file",
    )
    main(parser.parse_args())

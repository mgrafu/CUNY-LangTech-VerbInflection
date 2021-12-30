#!/usr/bin/env python
"""Preprocess data file(s) into a fairseq compatible format."""

import argparse
import contextlib
import csv
import logging
import os.path

from typing import List, Tuple


def get_fs_compatible_name(path: str) -> Tuple[str, str]:
    path, file = os.path.split(path)
    if path.endswith("tmp"):
        path = path[:-3]
    name, _ = os.path.splitext(file)
    lang, sample = name.split("_")
    a_path = path + sample + "." + lang + ".inf"
    b_path = path + sample + "." + lang + ".pres"
    return a_path, b_path


def output_formatted_files(path: str) -> Tuple[str, str]:
    a_path, b_path = get_fs_compatible_name(path)
    with contextlib.ExitStack() as stack:
        source = csv.reader(
            stack.enter_context(open(path, "r")), delimiter="\t"
        )
        a_sink = stack.enter_context(open(a_path, "w"))
        b_sink = stack.enter_context(open(b_path, "w"))
        for a, b in source:
            prep_a = " ".join(a)
            prep_b = " ".join(b)
            print(prep_a, file=a_sink)
            print(prep_b, file=b_sink)
    return a_path, b_path


def main(args: argparse.Namespace) -> None:
    file_paths: List[str] = args.files
    for path in file_paths:
        a_path, b_path = output_formatted_files(path)
        logging.info(f"{path}\t>\t{a_path}\t{b_path}")


if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(levelname)s: %(message)s")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "files",
        nargs="+",
        help="file or list of files to reformat"
    )
    main(parser.parse_args())

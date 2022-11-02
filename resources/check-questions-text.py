#!/usr/bin/env python
import re

answer_regex = re.compile("^#+ answer", re.IGNORECASE)

def check_file(filepath):
    found_suspect_line = False
    print("Checking the lines of {fp}...".format(fp=filepath))
    with open(filepath) as f:
        for ix, line in enumerate(f):
            if answer_regex.match(line):
                found_suspect_line = True
                print("\tline number {ix} is suspect".format(ix=ix))
    return found_suspect_line


def main():
    offending_files = [
        "./example-{n}/example-{n}-questions.md".format(n=n) for n in range(3)
    ]
    checks = [(check_file(fp), fp) for fp in offending_files]
    print("\n")
    for is_suspect, fp in checks:
        if is_suspect:
            print("Found suspect line in {fp}".format(fp=fp))
        else:
            print("All lines look good in {fp}".format(fp=fp))

    return 0


if __name__ == '__main__':
    main()

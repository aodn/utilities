#!/usr/bin/env python3

import lxml.etree as ET
import os
import argparse
import sys


parser = argparse.ArgumentParser()
parser.add_argument("-s", "--source_dir", type=str, help="The directory containing the transformed dump")
parser.add_argument("-d", "--dest_dir", type=str, help="The destination for the list of sources (tag_values.csv)")
args = parser.parse_args()

if not args.source_dir:
    print("Missing source_dir")
    parser.print_help()
    sys.exit()
if not args.dest_dir:
    print("Missing dest_dir")
    parser.print_help()
    sys.exit()


def get_all_tag_values(source_dir, dest_dir):
    source_dir = os.path.normpath(source_dir)
    if not os.path.exists(source_dir):
        print("Invalid source directory.\nThe directory \"%s\" does not exist." % source_dir)

    dest_dir = os.path.normpath(dest_dir)
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    tag_values_dict = {}
    for subdir, dirs, files in os.walk(source_dir):
        if "67984a64-c5bd-485d-8ace-7b0b22806ffa" in subdir:
            continue
        for file in files:
            if file == "metadata.xml":
                dom = ET.parse(os.path.join(subdir, file))
                xslt = ET.parse("list-tags.xsl")
                transform = ET.XSLT(xslt)
                newdom = transform(dom)
                cleaned_newdom = ""
                for line in str(newdom).split("```"):
                    if not line.strip():
                        continue
                    cleaned_newdom += "%s\n" % line.replace("\n", "")
                    tag, value = line.strip().split("||")
                    if tag in tag_values_dict:
                        tag_values_dict[tag].append(str(value))
                    else:
                        tag_values_dict[tag] = [str(value)]

    with open(os.path.join(dest_dir, "tag_values.csv"), "w") as result_file:
        for tag, value_list in tag_values_dict.items():
            result_file.write(tag + "\n")
            # for value in set(value_list):
            #     result_file.write("'', '%s'\n" % value)


get_all_tag_values(args.source_dir, args.dest_dir)

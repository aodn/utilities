#!/usr/bin/env python3

import lxml.etree as ET
import os
import sys
import argparse
import zipfile
from shutil import copyfile
from match_tags import match_tags


def update_tag_values_dict(original_dict, new_values_dict):
    for tag, values_list in new_values_dict.items():
        if tag in original_dict:
            original_dict[tag].extend(values_list)
        else:
            original_dict[tag] = values_list
    return original_dict


def score_files(file_names, tags_found, used_tags):
    newly_scored_files = []
    for file_name in file_names:
        tags_in_this_file = []
        with open(file_name, "r") as fp:
            content = fp.readlines()
        num_found = 0
        tags_were_found = False
        for line in [x.replace("```", "").strip() for x in content]:
            tag = line.strip().split("||")[0]
            if tag in used_tags and tag not in tags_found and tag not in tags_in_this_file:
                num_found += 1
                tags_were_found = True
                tags_in_this_file.append(tag)
        if tags_were_found:
            newly_scored_files.append({"filename": file_name, "count": num_found})
    return sorted(newly_scored_files, reverse=True, key=lambda x: x.get("count", 0))


def prioritise_files(filenames, tags_to_find):
    prioritised_files = []
    found_tags = []
    list_of_filenames = filenames
    for i in range(0, len(filenames)):
        scored_files = score_files(list_of_filenames, found_tags, tags_to_find)

        try:
            best_record = scored_files.pop(0)
        except IndexError:
            break

        best_filename = best_record.get("filename")
        best_count = best_record.get("count")
        if best_count == 0:
            break

        prioritised_files.append(best_record)
        print("%s contains:" % best_filename)
        with open(best_filename, "r") as fp:
            content = fp.readlines()
            for line in [x.replace("```", "").strip() for x in content]:
                tag = line.strip().split("||")[0]
                if tag in tags_to_find and tag not in found_tags:
                    found_tags.append(tag)
                    print(tag)
        list_of_filenames = [item.get("filename") for item in scored_files]
    return prioritised_files


def extract_tags(rootdir, working_dir, filename):
    tags_used = []
    filenames_to_search = []
    for subdir, dirs, files in os.walk(rootdir):
        for file in files:
            if file == filename:
                dom = ET.parse(os.path.join(subdir, file))
                xslt = ET.parse("list-tags.xsl")
                transform = ET.XSLT(xslt)
                newdom = transform(dom)
                cleaned_newdom = ""
                for line in str(newdom).split("```"):
                    cleaned_newdom += "%s\n" % line.replace("\n", "")
                    tag = line.strip().split("||")[0]
                    if tag not in tags_used:
                        tags_used.append(tag)

                new_dir = subdir.replace(rootdir, working_dir)
                if not os.path.exists(new_dir):
                    os.makedirs(new_dir)
                copyfile(os.path.join(subdir, file), os.path.join(new_dir, file))  # Copy the file for easy comparison
                new_file_name = os.path.join(new_dir,  "%s.txt" % filename)
                filenames_to_search.append(new_file_name)
                with open(new_file_name, "w") as f:
                    f.write(cleaned_newdom)
    return tags_used, filenames_to_search


def create_sample_archive(working_dir, prioritised_files):
    print("\n\n\nStatistics:\n")
    with zipfile.ZipFile("samples.zip", "w") as z:
        print("Number of tags found - filename")
        for item in prioritised_files:
            print("%s - %s" % (item.get("count"), item.get("filename").replace(working_dir, "").replace(".txt", "/metadata/metadata.xml")))
            dir_name = item.get("filename").replace(working_dir, "").replace(".txt", "")
            # Iterate over all the files in directory
            for folderName, subfolders, filenames in os.walk(dir_name):
                for filename in filenames:
                    # Create complete filepath of file in directory
                    file_path = os.path.join(folderName, filename)
                    # Add file to zip
                    z.write(file_path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--source_dir", type=str, help="The metadata source directory")
    parser.add_argument("-d", "--dest_dir", type=str, help="The destination directory for output")
    args = parser.parse_args()

    if not args.source_dir:
        print("Missing source_dir")
        parser.print_help()
        sys.exit()
    if not args.dest_dir:
        print("Missing dest_dir")
        parser.print_help()
        sys.exit()

    source_dir = os.path.normpath(args.source_dir)
    if not os.path.exists(source_dir):
        print("Invalid source directory.\nThe directory \"%s\" does not exist." % source_dir)

    dest_dir = os.path.normpath(args.dest_dir)
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    # Extract tags from all files. Also adds a .txt file containing summary of all tags in file.
    tags_used, filenames_to_search = extract_tags(source_dir, dest_dir, "metadata.xml")

    # Find the lowest number of files to match all tags and prioritise them based on the number of tags
    prioritised_files = prioritise_files(filenames_to_search, tags_used)

    # Create an archive containing the sample files
    # create_sample_archive(dest_dir, prioritised_files)

    # Extract tags from 19115 records as well to compare
    extract_tags(source_dir, dest_dir, "metadata.iso19115-3.2018.xml")

    unmatched_content_19139 = []
    unmatched_content_19115 = []
    overall_matched_lines = []
    overall_tag_values_dict = {}
    for file in prioritised_files:
        metadata_dir = os.path.dirname(file.get("filename"))

        file_19193 = os.path.join(metadata_dir, "metadata.xml.txt")
        file_19115 = os.path.join(metadata_dir, "metadata.iso19115-3.2018.xml.txt")

        unmatched_19139, unmatched_19115, matched_lines, tag_values_dict = match_tags(metadata_dir, file_19193, file_19115)
        overall_matched_lines.extend(matched_lines)
        overall_tag_values_dict = update_tag_values_dict(overall_tag_values_dict, tag_values_dict)
        for tag, value in unmatched_19139:
            if tag not in set([pair[0] for pair in unmatched_content_19139]):
                unmatched_content_19139.append([tag, value])
        for tag, value in unmatched_19115:
            if tag not in set([pair[0] for pair in unmatched_content_19115]):
                unmatched_content_19115.append([tag, value])

    # Write results
    with open(os.path.join(dest_dir, "overall_matched_results.csv"), "w") as result_file:
        for matched_line in set(overall_matched_lines):
            result_file.write('"%s", "%s", "%s", "%s"\n' % tuple(matched_line))

    with open(os.path.join(dest_dir, "overall_unmatched_results.csv"), "w") as unmatched_result_file:
        for index in range(0, max(len(unmatched_content_19139), len(unmatched_content_19115))):
            try:
                line = '"%s", "%s"' % tuple(unmatched_content_19139[index])
            except IndexError:
                line = '"", ""'
            try:
                line = line + ', "%s", "%s"' % tuple(unmatched_content_19115[index])
            except IndexError:
                line = line + ', "", ""'
            finally:
                unmatched_result_file.write('%s\n' % line)


main()





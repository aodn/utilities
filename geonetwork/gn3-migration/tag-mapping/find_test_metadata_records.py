#!/usr/bin/env python3

import lxml.etree as ET
import os
import sys
import argparse
import zipfile

from datetime import datetime
from shutil import copyfile

MISSING = "MISSING"
SKIPPED = "SKIPPED"
DATE_FORMATS = ["%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%Y", "%Y-%m"]
TAGS_TO_SKIP = [

    # Schema
    "/mcp:MD_Metadata/@xsi:schemaLocation",
    "/mdb:MD_Metadata/@xsi:schemaLocation",
    "/mcp:MD_Metadata/@gco:isoType",

    "/mcp:MD_Metadata/gmd:metadataStandardVersion/gco:CharacterString",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/@gco:isoType",

    "/mcp:MD_Metadata/gmd:metadataStandardName/gco:CharacterString",

    # Scope Code?
    "/mcp:MD_Metadata/gmd:hierarchyLevel/gmx:MX_ScopeCode/@codeList",

    # Temporal Extent
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/@gco:isoType",

    # Profile:
    "/mdb:MD_Metadata/mdb:metadataProfile/cit:CI_Citation/cit:date/cit:CI_Date/cit:dateType/cit:CI_DateTypeCode/@codeList",

    # Telephone Type Code
    # Represented as tag in 19139 but attr in 19115
    "/mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode",
    "/mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeList",
    "/mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeListValue",
    "/mdb:MD_Metadata/mdb:identificationInfo/mri:MD_DataIdentification/mri:pointOfContact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeList",

    # Creative Commons
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:resourceConstraints/mcp:MD_Commons/@gco:isoType",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:resourceConstraints/mcp:MD_Commons/@mcp:commonsType",

    # Parameter Fields
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:platform/mcp:DP_Term/mcp:usedInDataset/gco:Boolean",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:platform/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterDeterminationInstrument/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterDeterminationInstrument/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeListValue",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:platform/mcp:DP_Term/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:platform/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeListValue",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterDeterminationInstrument/mcp:DP_Term/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterDeterminationInstrument/mcp:DP_Term/mcp:usedInDataset/gco:Boolean",

    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:usedInDataset/gco:Boolean",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeListValue",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:type/mcp:DP_TypeCode/@codeListValue",

    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_Term/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_Term/mcp:usedInDataset/gco:Boolean",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeListValue",

    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_UnitsName/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_UnitsName/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterUnits/mcp:DP_UnitsName/mcp:type/mcp:DP_TypeCode/@codeListValue",

    # Sampling Frequency
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:samplingFrequency/gmd:MD_MaintenanceFrequencyCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:samplingFrequency/gmd:MD_MaintenanceFrequencyCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:samplingFrequency/gmd:MD_MaintenanceFrequencyCode/@codeListValue",

    # Temporal Extent
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/mcp:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/@gco:isoType",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode/@codeListValue",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode/@codeListValue",

    # Misc
    "/mcp:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:offLine/gmd:MD_Medium/gmd:name/gmd:MD_MediumNameCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeList",

    # Scope
    "/mcp:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmx:MX_ScopeCode/@codeList",

    # Parameter Analysis Method
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:type/mcp:DP_TypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:usedInDataset/gco:Boolean",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:type/mcp:DP_TypeCode/@codeListValue",
]


def parse_date(date_str):
    for format in DATE_FORMATS:
        try:
            return datetime.strptime(date_str, format)
        except ValueError:
            pass
    return date_str


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


def create_sample_archive(working_dir, source_dir, prioritised_files):
    print("\n\n\nStatistics:\n")
    with zipfile.ZipFile(os.path.join(working_dir, "samples.zip"), "w") as z:
        print("Number of tags found - filename")
        for item in prioritised_files:
            print("%s - %s" % (item.get("count"), item.get("filename").replace(working_dir, "").replace(".txt", "")))
            dir_name = item.get("filename").replace(working_dir, source_dir).replace("metadata/metadata.xml.txt", "")
            # Iterate over all the files in directory
            for folderName, subfolders, filenames in os.walk(dir_name):
                for filename in filenames:
                    # Create complete filepath of file in directory
                    file_path = os.path.join(folderName, filename)
                    # Add file to zip
                    z.write(file_path)


def translate_value(original_value, tag):
    transformed_value = original_value

    # Mapping between schemas
    if "CI_RoleCode" in tag:
        if transformed_value == "coInvestigator":
            transformed_value = "collaborator"
        elif transformed_value == "metadataContact":
            transformed_value = "editor"
    elif "MD_ScopeCode" in tag:
        if transformed_value == "publication":
            transformed_value = "document"

    return transformed_value


def extract_tag_and_value(line):
    line = line.replace("```", "")  # Remove divider
    try:
        tag, value = [el.strip() for el in line.strip().split("||")]
    except ValueError as e:
        print("Unexpected convention. Tag and value should be separated by ||. Error on line:\n%s" % line)
        raise e

    if "#" in value:
        value = value[value.index("#")+1:]

    # Check if is datetime, if not datetime original value is returned
    value = parse_date(value)

    return tag, value


def match_tags(destination_dir, first_file, second_file, mapped_tags, dest_dir):

    try:
        with open(first_file, "r") as tagsused_file:
            content19139 = tagsused_file.readlines()
    except FileNotFoundError:
        print("19139 File Missing. %s" % first_file)
        return

    try:
        with open(second_file, "r") as tagsused_file:
            content19115 = tagsused_file.readlines()
    except FileNotFoundError:
        print("19115 File Missing. %s" % first_file)
        return

    matched_lines = []            # Contains the matched lines between the two files
    unmatched_content_19139 = []  # All elements of the first file that are not matched
    unmatched_content_19115 = []  # All elements of the second file that are not matched
    content19139_num_values = 0   # Content that does not include empty values
    tag_values_dict = {}

    for line in content19139:
        line = line.replace("```", "")  # Remove divider
        if not line.strip():
            continue
        try:
            tag_19139, value_19139 = extract_tag_and_value(line)
        except ValueError:
            continue

        if tag_19139 in tag_values_dict:
            tag_values_dict[tag_19139].append(str(value_19139))
        else:
            tag_values_dict[tag_19139] = [str(value_19139)]

        if tag_19139 in mapped_tags.keys():
            continue

        if not value_19139:
            continue

        # if tag_19139 in TAGS_TO_SKIP:
        #     continue

        # if tag_19139.lower().endswith("nilreason"):
        #     continue

        content19139_num_values += 1

        value_19139 = translate_value(value_19139, tag_19139)

        matched = False
        for line19115 in content19115:
            if not line19115.strip():
                continue

            try:
                tag_19115, value_19115 = extract_tag_and_value(line19115)
            except ValueError:
                continue

            if tag_19115 in TAGS_TO_SKIP:
                continue

            if not value_19115:
                continue

            if value_19139 == value_19115 and tag_19115 not in mapped_tags.values():
                keep_going = input("Do these tags match? (Enter y to confirm)\n19139: %s\n19115: %s\n\n" % (tag_19139, tag_19115))
                if keep_going.lower() != "y":
                    continue
                mapped_tags[tag_19139] = tag_19115
                # Re-fetch the original values
                tag_19139, value_19139 = [el.strip() for el in line.strip().split("||")]
                tag_19115, value_19115 = [el.strip() for el in line19115.strip().split("||")]
                matched_lines.append((tag_19139, value_19139, tag_19115, value_19115))
                with open(os.path.join(dest_dir, "confirmed_mappings.csv"), "a+") as mapping_file:
                    mapping_file.write("%s,%s\n" % (tag_19139, tag_19115))
                matched = True
                break

        if not matched:
            tag_19139, value_19139 = [el.strip() for el in line.strip().split("||")]
            unmatched_content_19139.append([tag_19139, value_19139])
            if tag_19139 in TAGS_TO_SKIP:
                mapped_tags[tag_19139] = None
                with open(os.path.join(dest_dir, "confirmed_mappings.csv"), "a+") as mapping_file:
                    mapping_file.write("%s,%s\n" % (tag_19139, SKIPPED))

    # Compile list of unmatched 19115 values
    matched_values_19115 = [line[3].replace("```", "") for line in matched_lines]
    for line in content19115:
        try:
            tag_19115, value_19115 = [el.strip() for el in line.strip().split("||")]
        except ValueError:
            continue

        if tag_19115 in TAGS_TO_SKIP:
            continue

        if value_19115 and value_19115 not in matched_values_19115:
            unmatched_content_19115.append([tag_19115, value_19115])

    # Write results
    with open(os.path.join(destination_dir, "matched_results.csv"), "w") as result_file:
        for matched_line in matched_lines:
            result_file.write('"%s", "%s", "%s", "%s"\n' % tuple(matched_line))

    # Write all the mappings
    for tag, value in unmatched_content_19139:
        if tag not in mapped_tags:
            mapped_tags[tag] = None
            with open(os.path.join(dest_dir, "confirmed_mappings.csv"), "a+") as mapping_file:
                mapping_file.write("%s,%s\n" % (tag, MISSING))

    # Write all the unmatched results. Maintaining order of discovery could assist with matching
    with open(os.path.join(destination_dir, "unmatched_results.csv"), "w") as unmatched_result_file:
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

    return unmatched_content_19139, unmatched_content_19115, matched_lines, tag_values_dict, mapped_tags


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
    create_sample_archive(dest_dir, source_dir, prioritised_files)

    # Extract tags from 19115 records as well to compare
    extract_tags(source_dir, dest_dir, "metadata.iso19115-3.2018.xml")

    mapped_tags = {}
    try:
        with open(os.path.join(dest_dir, "confirmed_mappings.csv"), "r+") as mapping_file:
            mapped_tags_list = mapping_file.readlines()
    except FileNotFoundError:
        mapped_tags_list = []
    for line in mapped_tags_list:
        tag_19139, tag_19115 = line.split(",")
        mapped_tags[tag_19139.strip()] = tag_19115.strip()

    unmatched_content_19139 = []
    unmatched_content_19115 = []
    overall_matched_lines = []
    overall_tag_values_dict = {}

    for file in prioritised_files:
        metadata_dir = os.path.dirname(file.get("filename"))

        file_19193 = os.path.join(metadata_dir, "metadata.xml.txt")
        file_19115 = os.path.join(metadata_dir, "metadata.iso19115-3.2018.xml.txt")
        try:
            unmatched_19139, unmatched_19115, matched_lines, tag_values_dict, mapped_tags = match_tags(metadata_dir, file_19193, file_19115, mapped_tags, dest_dir)
        except TypeError:
            continue
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





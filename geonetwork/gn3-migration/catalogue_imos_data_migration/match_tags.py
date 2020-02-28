import os
from datetime import datetime

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
    "/mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode",
    "/mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:phone/cit:CI_Telephone/cit:numberType/cit:CI_TelephoneTypeCode/@codeList",
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
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:beginTime/gco:DateTime",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:currency/mcp:MD_CurrencyTypeCode/@codeListValue",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/mcp:EX_TemporalExtent/mcp:temporalAggregation/mcp:MD_TemporalAggregationUnitCode/@codeListValue",

    # Initiative Type
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:initiativeType/gmd:DS_InitiativeTypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:initiativeType/gmd:DS_InitiativeTypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:initiativeType/gmd:DS_InitiativeTypeCode/@codeListValue",

    # Aggregate Information
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode/@codeList",
    "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode/@codeListValue",

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


    # ================================================================
    # NOT CARRIED ACROSS
    # Scope
    # "/mcp:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:levelDescription/gmd:MD_ScopeDescription/gmd:dataset/gco:CharacterString",

    # Credit
    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:credit/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:resourceConstraints/mcp:MD_Commons/mcp:otherConstraints/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:term/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterAnalysisMethod/mcp:DP_Term/mcp:vocabularyTermURL/gmd:URL",
    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:vocabularyListURL/gmd:URL",
    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:vocabularyServiceURL/gmd:URL",
    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:vocabularyListURL/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:name/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term/mcp:term/gco:CharacterString",

    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:collectiveTitle/gco:CharacterString",

    # Resource Constraints - merged in 19115-3
    # "/mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/gmd:resourceConstraints/mcp:MD_Commons/mcp:attributionConstraints/gco:CharacterString",

]


def parse_date(date_str):
    for format in DATE_FORMATS:
        try:
            return datetime.strptime(date_str, format)
        except ValueError:
            pass
    return date_str


def match_tags(destination_dir, first_file, second_file):

    try:
        with open(first_file, "r") as tagsused_file:
            content19139 = tagsused_file.readlines()
    except FileNotFoundError:
        print("19139 File Missing. %s" % first_file)

    try:
        with open(second_file, "r") as tagsused_file:
            content19115 = tagsused_file.readlines()
    except FileNotFoundError:
        print("19115 File Missing. %s" % first_file)

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
            tag_19139, value_19139 = [el.strip() for el in line.strip().split("||")]
        except ValueError as e:
            print("Unexpected convention. Tag and value should be separated by ||. Error on line:\n%s" % line)
            continue

        if tag_19139 in tag_values_dict:
            tag_values_dict[tag_19139].append(str(value_19139))
        else:
            tag_values_dict[tag_19139] = [str(value_19139)]

        if tag_19139 in TAGS_TO_SKIP:
            continue

        if not value_19139:
            continue

        content19139_num_values += 1

        # Mapping between schemas
        if "CI_RoleCode" in tag_19139:
            if value_19139 == "coInvestigator":
                value_19139 = "collaborator"
            elif value_19139 == "metadataContact":
                value_19139 = "editor"
        elif "MD_ScopeCode" in tag_19139:
            if value_19139 == "publication":
                value_19139 = "document"


        if "#" in value_19139:
            value_19139 = value_19139[value_19139.index("#")+1:]

        # Check if is datetime, if not datetime original value is returned
        value_19139 = parse_date(value_19139)

        matched = False
        for line19115 in content19115:
            if not line19115.strip():
                continue
            line19115 = line19115.replace("```", "")  # Remove divider
            try:
                tag_19115, value_19115 = [el.strip() for el in line19115.strip().split("||")]
            except ValueError as e:
                print("Unexpected convention. Tag and value should be separated by ||. Error on line:\n%s" % line19115)
                continue

            if tag_19115 in TAGS_TO_SKIP:
                continue

            if not value_19115:
                continue

            if "#" in value_19115:
                value_19115 = value_19115[value_19115.index("#")+1:]

            # Check if is datetime, if not same original value is returned
            value_19115 = parse_date(value_19115)

            if value_19139 == value_19115:
                tag_19139, value_19139 = [el.strip() for el in line.strip().split("||")]
                tag_19115, value_19115 = [el.strip() for el in line19115.strip().split("||")]
                matched_lines.append((tag_19139, value_19139, tag_19115, value_19115))
                matched = True
                break

        if not matched:
            tag_19139, value_19139 = [el.strip() for el in line.strip().split("||")]
            unmatched_content_19139.append([tag_19139, value_19139])

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

    print("%s - Matched %s of %s tags. (%s)" % (destination_dir, len(matched_lines), content19139_num_values, (len(matched_lines)/content19139_num_values)*100))
    return unmatched_content_19139, unmatched_content_19115, matched_lines, tag_values_dict

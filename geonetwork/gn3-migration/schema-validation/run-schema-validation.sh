#!/bin/bash

# perform schema validation
# $schema_plugins_path - Schema plugin path
# $record_path - 	Path for MEF exported metadata records folder
# $error_file -	Filename of the schema validation error file
check_schema_validation() {

	local schema_plugins_path=$1; shift
	local record_path=$1; shift
  local error_file=$1; shift

	for uuid in `ls -1 $record_path`
	do 
	  schema=`xmllint --xpath '//schema/text()' $record_path/$uuid/info.xml`
	  XML_CATALOG_FILES='$schema_plugins_path/$schema/oasis-catalog.xml' xmllint --schema "$schema_plugins_path/$schema/schema.xsd" --noout $record_path/$uuid/metadata/metadata.xml
	done >$error_file 2>&1

}

# find list of schema validation error type
# $error_file -	Filename of the schema validation error file
list_schema_validation_error() {

  local error_file=$1; shift

	cat $error_file | cut -f2- -d" " | sort | uniq -c | tr -s " " | cut -f3-4 -d" " |  tr -d ":" | uniq > list-$error_file

	sed -e "/validates/d" -e "/fails to/d" -i.original list-$error_file

}
# Produces additional error files
# $error_file -	Filename of the schema validation error file
process_schema_validation() {

  local error_file=$1; shift

  list_schema_validation_error $error_file

	 [ -e errors-detail-$error_file ] && rm errors-detail-$error_file
	 [ -e errors-uuid-$error_file ] && rm errors-uuid-$error_file

	while read line; do
		errorname=$( echo "$line"   )
		echo $errorname
		sed -n "/$line/p" $error_file > tmp.txt
		echo $errorname >> errors-detail-$error_file
		cat tmp.txt >> errors-detail-$error_file
		echo $errorname >> errors-uuid-$error_file
		cat tmp.txt | cut -f3 -d"/" | sort | uniq -c >> errors-uuid-$error_file
	done<list-$error_file

	[ -e tmp.txt  ] && rm tmp.txt

}

# Fixes schema validation errors
# $schema_plugins_path - Schema plugin path
# $record_path - 	Path for MEF exported metadata records folder
# $error_file -	Filename of the schema validation error file
fix_schema_validation() {

	local schema_plugins_path=$1; shift
	local record_path=$1; shift
  local error_file=$1; shift

#  list_schema_validation_error $error_file
#	error_list=$(<list-$error_file)
	error_list=("element type" "element levelDescription" "element function" "element duration" "element dateType" "element codeSpace" "element beginTime" "element alternativeTitle" "element URL" "element TimePeriod" "element Real" "element MD_Commons" "element Polygon"  "element EX_VerticalExtent"  "element EX_Extent" "element Distance" "element Decimal" "element DateTime" "element Date" "element DS_Initiative"  "element DS_DataSet" "element DQ_Scope" "element CharacterString" "element Boolean" )

	for error_type in "${error_list[@]}";
  do
    echo "$error_type"
  done

	for uuid in  `ls -1 $record_path`
	do 

	    schema=`xmllint --xpath '//schema/text()' $record_path/$uuid/info.xml`
	  	error=$( { XML_CATALOG_FILES='$schema_plugins_path/$schema/oasis-catalog.xml' xmllint --schema "$schema_plugins_path/$schema/schema.xsd" --noout $record_path/$uuid/metadata/metadata.xml; } 2>&1 )
      for error_type in "${error_list[@]}";
      do
        if [[ $error == *"$error_type"*  ]]
        then
          xsltproc -o $record_path/$uuid/metadata/metadata.xml fix-mcp-schema-validation.xsl $record_path/$uuid/metadata/metadata.xml

          tmp_error=$( { XML_CATALOG_FILES='$schema_plugins_path/$schema/oasis-catalog.xml' xmllint --schema "$schema_plugins_path/$schema/schema.xsd" --noout $record_path/$uuid/metadata/metadata.xml; } 2>&1 )

          "$tmp_error" =~ 'validates'$
          if [[ $? -ne 0 ]]; then
            echo "\n\n$error_type : ${uuid}"
            echo "Before Fix: \n${error}"
            echo "\nAfter Fix: \n${tmp_error}"
          fi
        fi
      done
	done
}


# prints usage and exit
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Description: A simple utility for metadata record schema validation"
    echo "Options:
  -s 	Schema plugin path 
  -r 	Path for MEF exported metadata records folder
  -e 	Filename of the schema validation error file"
    exit 3
}

main() {
    # parse options with getopt
    local tmp_getops
    tmp_getops=`getopt hs:r:e: $*`
    [ $? != 0 ] && usage

    set -- $tmp_getops
    local schema_plugins_path record_path error_file

    # parse the options
    while true ; do
        case "$1" in
            -h) usage;;
            -s) schema_plugins_path="$2"; shift 2;;
            -r) record_path="$2"; shift 2;;
            -e) error_file="$2"; shift 2;;
            --) shift; break;;
            *) usage;;
        esac
    done

    [ x"$schema_plugins_path" = x ] && usage
    [ x"$record_path" = x ] && usage
    [ x"$error_file" = x ] && usage

    check_schema_validation $schema_plugins_path $record_path $error_file
    fix_schema_validation $schema_plugins_path $record_path $error_file
	  check_schema_validation $schema_plugins_path $record_path "after-fix-"$error_file
    sed -i.all "/validates/d" "after-fix-"$error_file

}

main "$@"

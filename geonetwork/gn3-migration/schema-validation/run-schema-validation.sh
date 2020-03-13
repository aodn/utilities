#!/bin/bash

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

process_schema_validation() {

  local error_file=$1; shift

	cat $error_file | cut -f2- -d" " | sort | uniq -c > list-detail-$error_file
	cat list-detail-$error_file | tr -s " " | cut -f3-4 -d" " > list-$error_file

	 [ -e errors-detail-$error_file ] && rm errors-detail-$error_file
	 [ -e errors-uuid-$error_file ] && rm errors-uuid-$error_file

	while read line; do 
		errorname=$( echo "$line" | tr " " _ | tr -d ":"  )
		echo $errorname
		sed -n "/$line/p" $error_file > tmp.txt
		echo $errorname >> errors-detail-$error_file
		cat tmp.txt >> errors-detail-$error_file
		echo $errorname >> errors-uuid-$error_file
		cat tmp.txt | cut -f3 -d"/" | sort | uniq -c >> errors-uuid-$error_file
	done<list-$error_file

	[ -e tmp.txt  ] && rm tmp.txt

}

fix_schema_validation() {

	local schema_plugins_path=$1; shift
	local record_path=$1; shift
  local error_file=$1; shift

#	error_list=$(<$list-error_file)
	error_list=("element type" "element dateType" "element alternativeTitle" "element URL" "element TimePeriod" "element Real" "element MD_Commons" "element Polygon"  "element EX_VerticalExtent"  "element EX_Extent" "element Distance" "element DS_Initiative"  "element DS_DataSet" "element DQ_Scope" "element CharacterString" "element Boolean" )

#	for error_type in "${error_list[@]}";
#  do
#    echo "$error_type"
#  done


	# '2d2b2f92-12fa-4330-a480-94f0892c2b72' - element Boolean
	# '028d4759-7246-4419-979d-94f071b7be27' - element CharacterString
	# '07405f5e-2da8-4537-811c-25cf48f09116' - element DQ_Scope
	# 'c78801d0-bffe-11dc-a463-00188b4c0af8' - element DS_DataSet
	# 'c78801d0-bffe-11dc-a463-00188b4c0af8' - element DS_Initiative
	# '2d2b2f92-12fa-4330-a480-94f0892c2b72' - element EX_Extent
	# '0167bb49-b64d-463b-9c39-c36f4ae20dfc' - elementelement EX_VerticalExtent
	# '67984a64-c5bd-485d-8ace-7b0b22806ffa' - element MD_Commons
	# 'a8e379ef-e0f5-4614-b027-0c4e5f31aa9b' - element MD_Commons
	# '006bb7dc-860b-4b89-bf4c-6bd930bd35b7' - element Polygon
	# '0167bb49-b64d-463b-9c39-c36f4ae20dfc' - element Real
	# '006bb7dc-860b-4b89-bf4c-6bd930bd35b7' - element TimePeriod
	# '97b9fe73-ee44-437f-b2ae-5b8613f81042' - element URL
	# 'c1344979-f701-0916-e044-00144f7bc0f4' - element alternativeTitle
	# '091a4670-dacb-4cd7-b5e5-761c8c9d3bf1' - element dateType
	# '0ede6b3d-8635-472f-b91c-56a758b4e091' - element type


	for uuid in `ls -1 $record_path`  
	do 

	    schema=`xmllint --xpath '//schema/text()' $record_path/$uuid/info.xml`
	  	error=$( { XML_CATALOG_FILES='$schema_plugins_path/$schema/oasis-catalog.xml' xmllint --schema "$schema_plugins_path/$schema/schema.xsd" --noout $record_path/$uuid/metadata/metadata.xml; } 2>&1 )
      for error_type in "${error_list[@]}";
      do
        if [[ $error == *"$error_type"*  ]]
          then

            xsltproc -o $record_path/$uuid/metadata/metadata.xml fix-mcp-schema-validation.xsl $record_path/$uuid/metadata/metadata.xml

  			    tmp_error=$( { XML_CATALOG_FILES='$schema_plugins_path/$schema/oasis-catalog.xml' xmllint --schema "$schema_plugins_path/$schema/schema.xsd" --noout $record_path/$uuid/metadata/metadata.xml; } 2>&1 )

            echo "\n\n$error_type : ${uuid}"
            echo "Before Fix: \n${error}"
  				  echo "\nAfter Fix: \n${tmp_error}"
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
#    process_schema_validation $error_file
    fix_schema_validation $schema_plugins_path $record_path $error_file
	  check_schema_validation $schema_plugins_path $record_path "fixed-"$error_file

}

main "$@"








#!/bin/bash

# transforms unzipped mef records (of the type exported by gn-tool.sh)
#   where the uuid contains '{' and '}' characters

# usage: ./transform-braced-mefs.sh /path/to/mef/dir

DIR=$(echo $1 | sed 's:/*$::')
echo $DIR

ls $DIR | grep "{" | grep "}" | while read -r metadata_dir; do
    old_uuid=$metadata_dir
    tmp1=${old_uuid#"{"}
    new_uuid=${tmp1%"}"}

    # in-file replacement of uuids
    grep -rl $old_uuid $DIR/$metadata_dir | while read -r xml_file; do
        echo "updating $xml_file"
	echo "  changing $old_uuid to $new_uuid"
	sed -i -e "s/$old_uuid/$new_uuid/g" $xml_file
    done

    # update directory name
    mv $DIR/$metadata_dir $DIR/$new_uuid
done

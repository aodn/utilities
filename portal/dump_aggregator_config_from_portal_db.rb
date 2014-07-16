#!/usr/bin/ruby

# script to extract and format portal aggregator (aodaac,bodaac,gogoduck) configuration suitable to entered into geonetwork 
# Usage: db should be dumped and restored to localhost, then invoke,
# ./dump_aggregator_config_from_portal_db.rb -d portal_imos123_rc  

require 'pg'
require 'optparse'


def dump_aggregator_config_from_portal_db(conn)

  # extract services
  res = conn.exec( <<-EOS
    -- aodaac
    select 'aodaac' as type, layer_name as layer, product_id::varchar as field 
    from aodaac_product_link

    union all

    -- gogoduck case 1
    select 'gogoduck' as type, l.name as layer, l2.name as field
    from layer l
    left join server s on l.server_id = s.id
    left join layer l2 on l.wfs_layer_id = l2.id
    where l.wfs_layer_id is not null
    and s.type ~ 'NCWMS'

    union all

    -- gogoduck case 2
    select 'gogoduck' as type, name as layer, gogoduck_layer_name as field
    from layer
    where gogoduck_layer_name is not null

    union all

    -- bodaac
    select 'bodaac' as type, l.name as layer,
        case when s.type ~ 'NCWMS'
            then l2.name
            else l.name
        end
        ||'#'||l.url_download_field_name as field
    from layer l
    left join server s on l.server_id = s.id
    left join layer l2 on l.wfs_layer_id = l2.id
    where l.url_download_field_name is not null
    EOS
  )

  # organize aggregatable services in terms of layer
  mappings = {} 
  res.each { |row|
    (mappings[row['layer']] ||= []) << { type: row['type'], field: row['field'] } 
  } 

  # dump to stdout
  mappings.keys.each { |layer| 
    puts "#{layer}"
    mappings[layer].each { |service|
      puts "IMOS:AGGREGATION--#{service[:type]}"
      puts service[:field]
    } 
    puts ""
  }
end


# process the options
dbname = nil
OptionParser.new do |opts|
  opts.banner = "Usage: dump_aggregator_config_from_portal_db.rb [options]"
  # actions
  opts.on('-d', '--require dbname', 'Requires the dbname') { |v| dbname = v }
end.parse!

raise OptionParser::MissingArgument if dbname .nil? 

# dump it
dump_aggregator_config_from_portal_db( PG::Connection.open(:dbname => dbname))



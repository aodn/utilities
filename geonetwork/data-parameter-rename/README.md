# Metadata Data Parameter Renaming

This is a little Ruby script that can be used to rename data parameters in GeoNetwork.

It uses [Bundler](http://bundler.io) to manage the gem dependencies so you will need that installed
at the very least

`$ gem install bundler`

Then bundle

`$ bundle`

Then run it like `$ ruby rename_metadata_data_parameter.rb host database user password search_term replace_term`

E.g. `ruby rename_metadata_data_parameter.rb emii3-vm1.its.utas.edu.au imosmest postgres password fluorescence "fluorescence in sea water"`

It will print to stdout the uuids of any records it updates.

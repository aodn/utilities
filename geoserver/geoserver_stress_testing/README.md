

#  Testing Geoserver layer performance with Jmeter



1. Create and configure a testing Geoserver with at least one `_map` layer you wish to test
1. Install JMeter https://jmeter.apache.org/download_jmeter.cgi
1. Navigate to this folder to run all the following commands..

JMeter is a java tool with a GUI for creating sets of tests to test a servers performance. The GUI is used to define the tests while it is suggested to run the resulting tests on the command line in non-GUI mode

1. Open the JMeter GUI to configure the preconfigured test set

```$xslt
jmeter -t GeoserverStressTest.jmx
```

This will open the JMeter GUI
1. Change the global server, layername, workspace, configuration
    1. `server` is the domain name of a Geoserver (assuming an non production AWS instance)
    1. `workspace` eg: aodn or imos
    1. `layername` the WMS map layername 

![thingy](images/main.png) 

1. Save and close. GeoserverStressTest.jmx is now tailored ready to test your layer in the non-GUI mode
1. The current set of tests are a single WFS request with no BBOX or data limits and multiple WMS tile requests 

###### Run the test and repeat at least a few times
```
jmeter -n -t GeoserverStressTest.jmx
```
After the first run there will be a log file in the CWD called `[layername]_log.csv` 

###### Keep the log for long term comparisons!!
1. This same stress test can be run over and over and the corresponding log for the layer will be appended.

#### Get the graphs
The example command below uses the resulting log for a layer called `example_profile_map` graphing all the  stress test runs. This example creates an output folder called `ouput` from the log file. In that folder there is a HTML page index.html to open in a browser.

```
jmeter -g example_profile_map_log.csv -o output
```
To update the graphs after more stress tests
```$xslt
rm -rf output; 
jmeter -g example_profile_map_log.csv -o output; 
open output/index.html
```


###### Example all in one command (for Mac)

The command below cleans up the `output` folder and recreates from the log file and opens the html page containing the report graphs in one command (mac :) )

```$xslt
rm -rf output; jmeter -g example_profile_map_log.csv -o output; open output/index.html
```

# GeoserverStressTest.jmx further mods

1. Change the set of WMS requests with python or by hand coding

JMeter is looping on the contents of `australiaWMS.csv` to run the WMS tile requests. australiaWMS.csv was created using `wms_request.py` to create a a list bboxes and image sizes to return. Although `wms_request.py` could be run each time to create random tests the aim would be to benchmark by running the same load each time with only remaining variable be the layer data size or complexity.


Below is the command used to populate australiaWMS.csv


`python wms_request.py -count 100 -region 94 -85 180 0 -minsize 400 300 -maxsize 600 400 -minres 0.00137329 -maxres 0.009 > australiaWMS.csv`


https://github.com/boundlessgeo/workshops/blob/master/workshops/geoserver/performance/scripts/bbox-commands.txt


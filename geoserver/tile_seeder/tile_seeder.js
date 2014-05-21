#!/usr/bin/js

// lat should be between -90 and 90 and lon between -180 and 180, however, we 
// can get all sort of weird "wrapping" calls over here. Yuck!
var lonMin = -180;
var lonMax = 180;
var latMin = -90;
var latMax = 90;

// Static layers (QUERYABLE=false)
var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=false&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&";
var version = "1.1.1";

// 1.1.1, using SRS=
var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&";
var version = "1.1.1";

// 1.3.0, using CRS=, also flipping lon,lat to be lat,lon
var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.3.0&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&CRS=EPSG%3A4326&";
var version = "1.3.0";

// Returns true if rightBBox intersects with leftBBox
function intersects(leftBBox, rightBBox) {
    return !(
           rightBBox[0] > leftBBox[2]
        || rightBBox[2] < leftBBox[0]
        || rightBBox[1] > leftBBox[3]
        || rightBBox[3] < leftBBox[1]
    );
}

// Calculates a bounding box with a gutter, given a left,bottom coordinate and
// a gutter and tile dimension
function toBoundingBoxWithGutter(left, bottom, tileDimension, gutterDimension) {
    //gutterSize = gutter * tileDimension / (tileSizePx);

    var _right = left + tileDimension + gutterDimension;
    var _top = bottom + tileDimension + gutterDimension;
    var _left = left - gutterDimension;
    var _bottom = bottom - gutterDimension;

    return [_left, _bottom, _right, _top];
}

// For version 1.3.0, we'll need to flip lon and lat
function flipLonLat(bbox) {
    return [bbox[1], bbox[0], bbox[3], bbox[2]];
}

function generateTiles(zoomLevelStart, zoomLevelEnd, layerBBox, tileSizePx, gutterPx) {
    var boundingBoxes = [];

    for (var zoomLevel = zoomLevelStart; zoomLevel <= zoomLevelEnd; ++zoomLevel) {
        var tileDimension = 180.0 / Math.pow(2, zoomLevel);

        for (var lon = lonMin; lon <= lonMax; lon += tileDimension) {
            for (var lat = latMin; lat <= latMax; lat += tileDimension) {
                var gutterDimension = gutterPx * tileDimension / tileSizePx;
                var bbox = toBoundingBoxWithGutter(lon, lat, tileDimension, gutterDimension);
                if (intersects(layerBBox, bbox)) {
                    if (version == "1.3.0") {
                        boundingBoxes.push(flipLonLat(bbox));
                    } else {
                        boundingBoxes.push(bbox);
                    }
                }
            }
        }
    }

    return boundingBoxes;
}

function generateUrlsForBBoxes(
    boundingBoxes,
    geoserverAddress,
    layerName,
    tileSizePx,
    gutterPx
) {
    var url = "";
    var urls = [];
    for (var i in boundingBoxes) {
        url = geoserverAddress + "/" +
            "wms?LAYERS=" + layerName +
            openlayersQueryConstants;

        var width  = tileSizePx + (2 * gutterPx);
        var height = tileSizePx + (2 * gutterPx);

        url +=
            "BBOX=" + boundingBoxes[i] + "&" +
            "WIDTH=" + width + "&" +
            "HEIGHT=" + height

        urls.push(url);
    }

    return urls;
}

function main(commandLineArguments) {
    var command          = commandLineArguments[0];
    var zoomLevels       = commandLineArguments[1];
    var geoserverAddress = commandLineArguments[2];
    var layerName        = encodeURIComponent(commandLineArguments[3]);
    var tileSizePx       = parseInt(commandLineArguments[4]);
    var gutterPx         = parseInt(commandLineArguments[5]);
    var layerBBoxStr     = commandLineArguments[6];

    var zoomLevelStart = zoomLevels.split("-")[0];
    var zoomLevelEnd   = zoomLevels.split("-")[1] || zoomLevelStart;

    layerBBox = [-180, -90, 180, 90];
    if (layerBBoxStr && layerBBoxStr != "") {
        layerBBox = layerBBoxStr.split(",");
    }

    var boundingBoxes = generateTiles(zoomLevelStart, zoomLevelEnd, layerBBox, tileSizePx, gutterPx);

    var urls = generateUrlsForBBoxes(
        boundingBoxes,
        geoserverAddress,
        layerName,
        tileSizePx,
        gutterPx
    );

    for (var i in urls) {
        print("squidclient -v -s -m " + command + " '" + urls[i] + "'");
    }
}

main(arguments);


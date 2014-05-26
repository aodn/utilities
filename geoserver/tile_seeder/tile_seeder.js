#!/usr/bin/js

// lat should be between -90 and 90 and lon between -180 and 180, however, we 
// can get all sort of weird "wrapping" calls over here. Yuck!
var lonMin = -180;
var lonMax = 180;
var latMin = -90;
var latMax = 90;

// Static layers (QUERYABLE=false)
//var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=false&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&";
//var version = "1.1.1";

// 1.1.1, using SRS=
var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&";
var version = "1.1.1";

// 1.3.0, using CRS=, also flipping lon,lat to be lat,lon
//var openlayersQueryConstants = "&TRANSPARENT=TRUE&VERSION=1.3.0&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&CRS=EPSG%3A4326&";
//var version = "1.3.0";

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

// layerBBOX can be null!
function generateTiles(zoomLevel, layerBBox, tileSizePx, gutterPx) {
    var boundingBoxes = [];

    // Tile dimension in degress
    var tileDimension = 180.0 / Math.pow(2, zoomLevel);
    // Gutter dimension in degress
    var gutterDimension = gutterPx * tileDimension / tileSizePx;

    for (var lon = lonMin; lon <= lonMax; lon += tileDimension) {
        for (var lat = latMin; lat <= latMax; lat += tileDimension) {
            var bbox = toBoundingBoxWithGutter(lon, lat, tileDimension, gutterDimension);
            if (layerBBox == null || intersects(layerBBox, bbox)) {
                if (version == "1.3.0") {
                    boundingBoxes.push(flipLonLat(bbox));
                } else {
                    boundingBoxes.push(bbox);
                }
            }
        }
    }

    return boundingBoxes;
}

function generateUrlsForBBoxes(
    boundingBoxes,
    layerName,
    tileSizePx,
    gutterPx
) {
    var url = "";
    var urls = [];
    for (var i in boundingBoxes) {
        url = "wms?LAYERS=" + layerName +
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
    var zoomLevel        = commandLineArguments[0];
    var layerName        = encodeURIComponent(commandLineArguments[1]);
    var tileSizePx       = parseInt(commandLineArguments[2]);
    var gutterPx         = parseInt(commandLineArguments[3]);
    var layerBBoxStr     = commandLineArguments[4];

    var layerBBox = null;
    if (layerBBoxStr && layerBBoxStr != "") {
        layerBBox = layerBBoxStr.split(",");
    }

    var boundingBoxes = generateTiles(zoomLevel, layerBBox, tileSizePx, gutterPx);

    var urls = generateUrlsForBBoxes(
        boundingBoxes,
        layerName,
        tileSizePx,
        gutterPx
    );

    for (var i in urls) {
        print(urls[i]);
    }
}

main(arguments);


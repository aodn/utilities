# About

This will upload and index Geonetwork metadata.xml documents from a collection of Geonetwork MEFs to an
AWS OpenSearch service. For geo-spatial searching of extents [define a `geo_shape` mapping](#define-a-geo_shape-mapping). 

# Usage: 

```
./opensearch.py <source directory containing geonetwork MEFs> <url to index/search service> <optional aws profile>
```

The source directory can be on the local file system or an S3 bucket in https://s3-ap-southeast-2.amazonaws.com. If using
S3 the source directory should be of the form ```s3://<bucket><path to directory containing MEFs>```

```
Local path example: 
  ./opensearch.py ~/catalogue-imos-dump https://search-example.ap-southeast-2.es.amazonaws.com 
S3 example: 
  ./opensearch.py s3://example/catalogue-imos-dump https://search-example.ap-southeast-2.es.amazonaws.com nonproduction-admin
```

AWS profile is required if using s3 and must be configured on local host.

# Sample OpenSearch queries

## Cluster health
```
GET _cluster/health?pretty
```
## Delete index
```
DELETE /catalogue-imos
```

## [Define a geo_shape mapping]
This is needed for geo-spatial searches of spatial_extent.
Delete the index first.
```
PUT /catalogue-imos
{
  "mappings": {
    "properties": {
      "spatial_extent": {
        "type": "geo_shape"
      }
    }
  }
}
```

## All documents in the index (Paginated)
```
GET catalogue-imos/_search
{
  "from": 5,
  "size": 20,  
  "query": {
    "match_all": {}
  }
}
```
## Get by _id
```
GET catalogue-imos/_doc/4402cb50-e20a-44ee-93e6-4728259250d2
```
## Search on uuid
```
GET catalogue-imos/_search
{
  "query": {
    "match": {
    "uuid": "4402cb50"
    }
  }
}
```
## Search on title
```
GET catalogue-imos/_search
{
  "query": {
    "match": {
    "title": "argo"
    }
  }
}
```

## Search on point of truth

Returns default first page of 10
```
GET catalogue-imos/_search
{
  "query": {
    "match": {
    "point_of_truth": "catalogue-imos"
    }
  }
}
```

## SQL plugin
### Search all
```
POST _plugins/_sql?format=json
{
  "query": "SELECT * FROM catalogue-imos"
}
```
### Search date in temporal extent

#### format=json
This does not work at time of writing due to unknown issue.
```
POST _plugins/_sql?format=json
{
  "query": "SELECT * FROM catalogue-imos where date('2015-06-01') >= date(temporal_extent_begin) and (date('2015-06-01') <= date(temporal_extent_end) or isnull(temporal_extent_end))"
}
```
#### default format
```
POST _plugins/_sql
{
  "query": "SELECT * FROM catalogue-imos where date('2015-06-01') >= date(temporal_extent_begin) and (date('2015-06-01') <= date(temporal_extent_end) or isnull(temporal_extent_end))"
}
```
## Search organisations
```
GET catalogue-imos/_search
{
  "query": {
    "match": {
    "organisations": "University"
    }
  }
}
```

## Geospatial

### Search for intersection with bounding box
This does not work but perhaps should due to this recent change: https://github.com/opensearch-project/OpenSearch/pull/2506

```
GET catalogue-imos/_search
{
  "query": {
    "bool": {
      "must": {
        "match_all": {}
      },
      "filter": {
        "geo_bounding_box": {
          "spatial_extent": {
            "top_left": {
              "lat": -42.5,
              "lon": 145.5
            },
            "bottom_right": {
              "lat": -43.5,
              "lon": 150.5
            }
          }
        }
      }
    }
  }
}
```
### Search for intersection with shape (this one is a bounding box)
```
GET catalogue-imos/_search
{
  "query": {
    "bool": {
      "must": {
        "match_all": {}
      },
      "filter": {
        "geo_shape": {
          "spatial_extent": {
            "shape": {
              "type": "envelope",
              "coordinates": [ [ 137, -39 ], [ 143, -45 ] ]
            },
            "relation": "intersects"
          }
        }
      }
    }
  }
}
```

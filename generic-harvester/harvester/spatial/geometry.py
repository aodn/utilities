"""
Geometry support

"""


def point(x, y, srid=4326):
    # postgis EWKT https://postgis.net/docs/ST_GeomFromEWKT.html
    return "SRID={};POINT({} {})".format(srid, x, y)

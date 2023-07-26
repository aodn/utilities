-- FUNCTION: public.boundingpolygonasgml3(text, text, text, double precision)

-- DROP FUNCTION IF EXISTS public.boundingpolygonasgml3(text, text, text, double precision);

CREATE OR REPLACE FUNCTION public.boundingpolygonasgml3(
	p_schema_name text,
	p_table_name text,
	p_column_name text,
	p_resolution double precision)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
GML_3_1_1 CONSTANT integer := 3; -- GML version
    boundingPolygonAsGml text;
BEGIN
    boundingPolygonAsGml := ST_AsGml(GML_3_1_1, BoundingPolygon(p_schema_name, p_table_name, p_column_name, p_resolution));
    boundingPolygonAsGml := add_id_to_polygons(boundingPolygonAsGml);
RETURN replace(boundingPolygonAsGml, 'EPSG:4326', 'CRS:84');
END;
$BODY$;

ALTER FUNCTION public.boundingpolygonasgml3(text, text, text, double precision)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.boundingpolygonasgml3(text, text, text, double precision) TO PUBLIC;

-- FUNCTION: public.boundingpolygon(text, text, text, double precision)

-- DROP FUNCTION IF EXISTS public.boundingpolygon(text, text, text, double precision);

CREATE OR REPLACE FUNCTION public.boundingpolygon(
	p_schema_name text,
	p_table_name text,
	p_column_name text,
	p_resolution double precision)
    RETURNS geometry
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE

AS $BODY$
DECLARE
result text;
BEGIN
    -- Create bounding polygon by finding grid cells that intersect at least one geometry in the
    -- specified table, aggregating them into one multi-polygon, removing any common boundaries using st_union
    -- and then simplifying (joining line segments that can be joined without changing the shape of the polygon)

EXECUTE 'SELECT st_simplify(st_union(cell), 0)
               FROM create_grid_cells('||p_resolution||') AS grid_cell
              WHERE exists (
                  SELECT true
                    FROM '||p_schema_name||'.'||p_table_name||'
                   WHERE '||p_column_name||' && grid_cell.cell
                     AND st_intersects('||p_column_name||', grid_cell.cell)
                   LIMIT 1
              )'
    INTO result;

RETURN result;
END;
$BODY$;

ALTER FUNCTION public.boundingpolygon(text, text, text, double precision)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.boundingpolygon(text, text, text, double precision) TO PUBLIC;

-- FUNCTION: public.create_grid_cells(double precision)

-- DROP FUNCTION IF EXISTS public.create_grid_cells(double precision);

CREATE OR REPLACE FUNCTION public.create_grid_cells(
	p_resolution double precision,
	OUT "row" integer,
	OUT col integer,
	OUT cell geometry)
    RETURNS SETOF record
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE STRICT PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY (
    SELECT fishnet."row", fishnet.col, fishnet.cell
            FROM st_createfishnet((180/p_resolution)::integer, (360/p_resolution)::integer, p_resolution, p_resolution, -180, -90) AS fishnet
    );
END
$BODY$;

ALTER FUNCTION public.create_grid_cells(double precision)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.create_grid_cells(double precision) TO PUBLIC;

-- FUNCTION: public.st_createfishnet(integer, integer, double precision, double precision, double precision, double precision, integer)

-- DROP FUNCTION IF EXISTS public.st_createfishnet(integer, integer, double precision, double precision, double precision, double precision, integer);

CREATE OR REPLACE FUNCTION public.st_createfishnet(
	p_nrow integer,
	p_ncol integer,
	p_xsize double precision,
	p_ysize double precision,
	p_x0 double precision DEFAULT 0,
	p_y0 double precision DEFAULT 0,
	p_srid integer DEFAULT 4326,
	OUT "row" integer,
	OUT col integer,
	OUT cell geometry)
    RETURNS SETOF record
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE STRICT PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY (
    SELECT i + 1 AS row, j + 1 AS col, ST_Translate(geom, j * p_xsize + p_x0, i * p_ysize + p_y0) AS cell
        FROM generate_series(0, p_nrow - 1) AS i,
                         generate_series(0, p_ncol - 1) AS j,
                         (
                             SELECT st_setsrid(('POLYGON((0 0, 0 '||p_ysize||', '||p_xsize||' '||p_ysize||', '||p_xsize||' 0,0 0))')::geometry, p_srid) AS geom
                         ) AS foo
    );
END
$BODY$;

ALTER FUNCTION public.st_createfishnet(integer, integer, double precision, double precision, double precision, double precision, integer)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.st_createfishnet(integer, integer, double precision, double precision, double precision, double precision, integer) TO PUBLIC;

-- FUNCTION: public.add_id_to_polygons(text)

-- DROP FUNCTION IF EXISTS public.add_id_to_polygons(text);

CREATE OR REPLACE FUNCTION public.add_id_to_polygons(
	p_gml text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
parts text[];
    result text;
BEGIN
    IF (p_gml is null) THEN
        RETURN null;
END IF;

    result := '';
    parts := regexp_split_to_array(p_gml, '<gml:Polygon');

FOR i IN 1..array_length(parts, 1)-1 LOOP
        result := result||parts[i]||'<gml:Polygon gml:id="polygon'||i||'"';
END LOOP;

    result := result||parts[array_length(parts, 1)];
RETURN result;
END;
$BODY$;

ALTER FUNCTION public.add_id_to_polygons(text)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.add_id_to_polygons(text) TO PUBLIC;

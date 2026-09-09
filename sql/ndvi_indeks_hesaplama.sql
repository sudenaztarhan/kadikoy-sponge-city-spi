CREATE TABLE kadikoy_ndvi_raster AS
SELECT 
    b8.rid,
    ST_MapAlgebra(
        b8.rast, 1, 
        b4.rast, 1, 
        '(([rast1] - [rast2])::float / NULLIF(([rast1] + [rast2])::float, 0))::float', 
        '32BF'
    ) AS rast
FROM kadikoy_b08 b8
JOIN kadikoy_b04 b4 ON b8.rid = b4.rid;
CREATE INDEX idx_kadikoy_ndvi_rast ON kadikoy_ndvi_raster USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('public'::name, 'kadikoy_ndvi_raster'::name, 'rast'::name);

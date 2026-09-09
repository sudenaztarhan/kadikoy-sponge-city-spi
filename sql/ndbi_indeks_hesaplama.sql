CREATE TABLE kadikoy_ndbi_raster AS
SELECT 
    b8.rid,
    ST_MapAlgebra(
        ST_Resample(b11.rast, b8.rast), 1, 
        b8.rast, 1, 
        '(([rast1] - [rast2])::float / NULLIF(([rast1] + [rast2])::float, 0))::float', 
        '32BF'
    ) AS rast
FROM kadikoy_b11 b11
JOIN kadikoy_b08 b8 ON b11.rid = b8.rid;
CREATE INDEX idx_kadikoy_ndbi_rast ON kadikoy_ndbi_raster USING gist (ST_ConvexHull(rast));
SELECT AddRasterConstraints('public'::name, 'kadikoy_ndbi_raster'::name, 'rast'::name);

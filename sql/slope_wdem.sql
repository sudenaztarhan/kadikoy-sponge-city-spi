CREATE TABLE dem_slope_10m AS --dem verisinden eğim üretilmesi
SELECT 
    id,
    ST_SetSRID(
        ST_Slope(
            rast, 
            1,          
            '32BF',   
            'degrees'  
        ), 
        5254
    ) AS rast
FROM dem_10m;

CREATE INDEX idx_slope_10m ON dem_slope_10m USING gist (ST_ConvexHull(rast));
ALTER TABLE dem_slope_10m ADD COLUMN id_pk SERIAL PRIMARY KEY; --kısıtların eklenmesi
SELECT AddRasterConstraints('dem_slope_10m'::name, 'rast'::name);
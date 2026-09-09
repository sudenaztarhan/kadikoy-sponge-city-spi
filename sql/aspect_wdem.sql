CREATE TABLE dem_aspect_10m AS --dem verisinden bakı üretilmesi
SELECT 
    id,
    ST_SetSRID(
        ST_Aspect(
            rast, 
            1,        
            '32BF'      
        ), 
        5254
    ) AS rast
FROM dem_10m;

CREATE INDEX idx_aspect_10m ON dem_aspect_10m USING gist (ST_ConvexHull(rast));
ALTER TABLE dem_aspect_10m ADD COLUMN id_pk SERIAL PRIMARY KEY; --kısıtların eklenmesi
SELECT AddRasterConstraints('dem_aspect_10m'::name, 'rast'::name);
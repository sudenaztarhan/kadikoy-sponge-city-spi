CREATE TABLE dem_10m AS --27m olan dem 10m'ye düşürüldü
SELECT 
    ST_SetSRID(
        ST_Resample(
            rast, 
            10.0, 10.0,         
            NULL, NULL,          
            0.0, 0.0,             
            'Cubic'               
        ), 
        5254
    ) AS rast
FROM dem_kes;

CREATE INDEX idx_dem_10m_rast ON dem_10m USING gist (ST_ConvexHull(rast));
ALTER TABLE dem_10m ADD COLUMN id SERIAL PRIMARY KEY; --qgise ekleme sıkıntısı olduğundan kısıtlar eklendi
SELECT AddRasterConstraints('dem_10m'::name, 'rast'::name);
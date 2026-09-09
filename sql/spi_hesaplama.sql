-- Mahalle sınırları ile raster indeksleri çakıştırarak LATERAL JOIN 
-- üzerinden ortalama değerleri hesaplar ve nihai SPI skorunu üretir.
-- Not: 'mahalle_sinirlari' kısmını kendi veritabanınızdaki poligon tablo adıyla değiştirebilirsiniz.

NDVI ve NDBI Kullanarak Betonlaşma Maskesi Üretimi
CREATE TABLE kadikoy_betonlasma_maske AS 
SELECT 
    ST_MapAlgebra(
        n.rast, 1, 
        b.rast, 1, 
        '([rast1.val] - [rast2.val])'
    ) AS rast
FROM kadikoy_ndbi_normalized n 
JOIN kadikoy_ndvi_normalized b 
ON ST_Intersects(n.rast, b.rast);

-- SPI Hesaplama ve Sonuç Tablosu Oluşturma
CREATE TABLE kadikoy_spi_sonuc AS
SELECT 
    m.adi_numarasi, 
    m.poly,
    ndvi_s.mean AS ndvi_ort,
    ndbi_s.mean AS ndbi_ort,
    tci_s.mean AS tci_ort,
    slope_s.mean AS slope_ort,
    (
      COALESCE(ndvi_s.mean, 0) * 0.30 + 
      COALESCE(tci_s.mean, 0) * 0.25 + 
      COALESCE(slope_s.mean, 0) * 0.15 - 
      COALESCE(ndbi_s.mean, 0) * 0.30
    ) AS spi_skoru
FROM mahalle_sinirlari m

LEFT JOIN LATERAL (
    SELECT (ST_SummaryStats(ST_Clip(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)), true), 1, true)).mean AS mean
    FROM kadikoy_ndvi_normalized r
    WHERE ST_Intersects(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)))
) ndvi_s ON true

LEFT JOIN LATERAL (
    SELECT (ST_SummaryStats(ST_Clip(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)), true), 1, true)).mean AS mean
    FROM kadikoy_ndbi_normalized r
    WHERE ST_Intersects(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)))
) ndbi_s ON true

LEFT JOIN LATERAL (
    SELECT (ST_SummaryStats(ST_Clip(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)), true), 1, true)).mean AS mean
    FROM tci r
    WHERE ST_Intersects(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)))
) tci_s ON true

LEFT JOIN LATERAL (
    SELECT (ST_SummaryStats(ST_Clip(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)), true), 1, true)).mean AS mean
    FROM dem_slope_10m r
    WHERE ST_Intersects(r.rast, ST_SetSRID(m.poly, ST_SRID(r.rast)))
) slope_s ON true;
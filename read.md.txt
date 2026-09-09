# Kadıköy Sünger Şehir Uygunluk Modeli (SPI)

> Kentsel su emme kapasitesini ve taşkın azaltma potansiyelini mahalle bazında değerlendirmek için PostgreSQL, PostGIS ve QGIS kullanan mekânsal analiz iş akışı projesi.

---

## **Proje Amacı**
Hızlı kentleşme ve geçirimsiz yüzeylerin artışı, doğal hidrolojik döngüyü bozarak aşırı yağışlar sırasında kentsel taşkın riskini artırmaktadır. Geleneksel gri altyapı çözümleri bu dinamiklerle başa çıkmakta sıklıkla yetersiz kalmaktadır. Bu proje, Kadıköy için yüksek riskli geçirimsiz bölgeleri ve doğal su tutma alanlarını tespit etmek amacıyla otomatikleştirilmiş bir **Sünger Potansiyel İndeksi (SPI)** modeli geliştirir.

Manuel masaüstü CBS iş akışlarına bağımlı kalmak yerine bu proje, yüksek performanslı mekânsal veri işleme için **PostgreSQL / PostGIS** altyapısını kullanır. Bitki örtüsü sağlığı, yapılaşma yoğunluğu, topografya ve yüzey eğimini ağırlıklı tek bir indeks altında birleştiren model; şehir plancılarına yeşil altyapı yerleşimi, sürdürülebilir kentsel planlama ve taşkın riski yönetimi için veriye dayalı görüşler sunar.

---

## **Metodoloji ve Matematiksel Model**
Sünger Potansiyel İndeksi (SPI), su emilimini destekleyen parametrelerle yüzey akışını tetikleyen unsurları dengeleyen çok kriterli ağırlıklı bir formülle hesaplanır:

SPI = (NDVI \times 0.30) + (TCI \times 0.25) + (Slope \times 0.15) - (NDBI \times 0.30)

* **NDVI (Normalleştirilmiş Fark Bitki Örtüsü İndeksi) | Ağırlık: +0.30:** Bitki örtüsü sağlığını ve yeşil altyapı yoğunluğunu temsil eder; toprağa sızmayı ve buharlaşmayı teşvik eder.
* **TCI (Topografik Nem İndeksi) | Ağırlık: +0.25:** Eğime ve yukarı akış havza büyüklüğüne bağlı olarak suyun birikme potansiyelini ölçer, doğal su toplama ceplerini belirler.
* **Slope (Eğim) | Ağırlık: +0.15:** Düzenleyici bir faktör olarak görev yapar; orta düzey eğimler sızmayı desteklerken, çok dik yamaçlar akışı hızlandırır.
* **NDBI (Normalleştirilmiş Fark Yapılaşma İndeksi) | Ağırlık: -0.30:** Beton, asfalt ve geçirimsiz yüzey yoğunluğunu nicelleştirir; taşkın duyarlılığını artıran negatif bir bileşen olarak etki eder.

---

## **PostGIS Mekânsal İş Akışı ve Optimizasyon**
Veri tabanı işlemleri hız ve analitik verimlilik açısından şu adımlarla optimize edilmiştir:
1. **Mekânsal İndeksleme:** Mekânsal sorguları ve kırpma operasyonlarını hızlandırmak için tüm vektör geometrileri ve raster sınır kutuları (`ST_ConvexHull`) üzerinde GiST indeksleri (`USING gist`) oluşturulmuştur.
2. **Otomatik Zonal İstatistikler:** Her mahalle poligonu sınırları içindeki ortalama raster değerlerini anında hesaplamak için `ST_SetSRID`, `ST_Clip` ve `ST_SummaryStats` fonksiyonlarıyla birlikte `LATERAL JOIN` yapısı kullanılmıştır.
3. **Bağımsız Çıktı Üretimi:** Orijinal idari sınır tablosu (`geomahalle`) değiştirilmeden; tüm parametre ortalamalarını ve nihai SPI skorlarını içeren, tamamen bağımsız bir sonuç tablosu (`kadikoy_spi_sonuc`) üretilmiştir.

## Drenaj Yönü ve Akış Birikimi (Flow Accumulation) Verilerinin Üretilmesi

Depo boyutunu optimize etmek ve veri lisans kısıtlamalarına uyum sağlamak amacıyla **Drenaj Yönü** ve **Number of Cells That Drain Through (Flow Accumulation)** raster katmanları bu repoda yer almamaktadır. Kendi Sayısal Yükseklik Modeli (DEM) verinizi kullanarak bu katmanları QGIS içerisinden şu adımlarla kolayca üretebilirsiniz:

1. **İşlem Araç Kutusunu Açın:** QGIS üst menüsünden `Görünüm > Paneller > İşlem Araç Kutusu` (Processing Toolbox) seçeneğini aktif edin.
2. **Hidrolojik Analiz Araçları:** Arama çubuğuna **"Flow Accumulation"** veya **"Watershed"** yazarak SAGA GIS veya GRASS GIS modüllerine ulaşın (Örn: *GRASS r.watershed* veya *SAGA* hidroloji araçları).
3. **Drenaj Yönü (Flow Direction):** Hazırladığınız 10m çözünürlükteki DEM katmanını girdi olarak vererek suyun akış yönünü gösteren **Drenaj Yönü** rasterını oluşturun.
4. **Akış Birikimi (Flow Accumulation):** Akış yönü çıktısını veya doğrudan DEM verisini kullanarak her bir pikselden su akış miktarını hesaplayan **Number of Cells That Drain Through** raster katmanını türetin.
5. **TCI Entegrasyonu:** Ürettiğiniz bu akış birikimi ve eğim katmanlarını kullanarak Topografik Nem İndeksi (**TCI**) katmanınızı elde edebilir ve veritabanına aktarabilirsiniz.

## **Veri Durumu ve Sorumluluk Reddi**
İdari sınır poligon katmanı (geomahalle - Kadıköy mahalle sınırları) ve orijinal yüksek çözünürlüklü raster veri setleri (Sentinel-2 türevleri, SRTM DEM), veri lisans kısıtlamaları ve dosya boyutu sınırlamaları nedeniyle bu repoda bulunmamaktadır.

Bu iş akışını kendi bölgenizde tekrarlamak için:

Kendi bölge sınır poligonlarınızı ve normalize edilmiş raster katmanlarınızı (NDVI, NDBI, TCI, Slope) PostGIS veri tabanınıza yükleyin.

sql/ dizini içinde sağlanan sorguları eşleşen tablo yapılarıyla çalıştırın.
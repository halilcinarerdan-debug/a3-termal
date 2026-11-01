/*
    Fonksiyon: RTI_fnc_sensorPolarity
    Çalışma yeri: İstemci

    Termal paletin kutbunu verir: 0 = beyaz sıcak (sıcak = parlak), 1 = siyah sıcak (sıcak = koyu).

    Ayar "Beyaz sıcak" / "Siyah sıcak" ise doğrudan o değer. "Otomatik" ise oyunun bildirdiği
    FLIR indeksine bakılır: currentVisionMode [birim] -> [görüşModu, flirIndeksi]
    (BI wiki currentVisionMode, Arma 3 2.08+). İndeks -> palet eşlemesi (siyah sıcak olanlar)
    RTI_sensor_blackHotIndices içindedir; bu eşleme setCamUseTI sayfasından DOĞRULANMADI
    (hafızadan: 1, 3, 5). Yanlışsa ayarı elle seç ya da diziyi düzelt.

    Parametreler: yok
    Dönüş: NUMBER - 0 ya da 1
*/

private _setting = RTI_sensor_polarity;

if (_setting != 2) exitWith {_setting};

private _flir = (currentVisionMode [player]) param [1, 0];

parseNumber (_flir in RTI_sensor_blackHotIndices)

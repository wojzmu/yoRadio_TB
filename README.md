# yoRadio na Waveshare ESP32-S3-Touch-LCD-2.8

Fork projektu [yoRadio_TB](https://github.com/tomaszbunio/yoRadio_TB) (v8.8.2_TB, Tomasz Bunio),
przeniesiony na gotową płytkę **Waveshare ESP32-S3-Touch-LCD-2.8**.
Radio internetowe działa na tej płytce bez żadnego dodatkowego okablowania: ekran, dotyk, DAC i wzmacniacz z głośnikiem są na płytce.

Pierwotny yoRadio_TB jest przeznaczony dla płytek składanych samodzielnie (ESP32-S3 + osobny wyświetlacz ILI9341/ILI9488,
dotyk XPT2046, DAC PCM5102A, enkodery, IR, NeoPixel). Konfiguracja autora została zachowana — zmiany dla płytki Waveshare
są włączane warunkiem `DSP_MODEL == DSP_ST7789` w `myoptions.h`.

## Obsługiwana płytka

| Element | Waveshare ESP32-S3-Touch-LCD-2.8 |
|---|---|
| Mikrokontroler | ESP32-S3R8, 16 MB flash, 8 MB PSRAM |
| Ekran | 2,8" IPS 240×320, **ST7789T3** (SPI), używany poziomo 320×240 |
| Dotyk | pojemnościowy **CST328** (I2C, adres 0x1A) — testowana wersja V1 płytki |
| Audio | DAC **PCM5101** (I2S) → wzmacniacz → głośnik |
| USB | USB-C do natywnego USB ESP32-S3 (USB-Serial/JTAG, bez mostka UART) |

| Funkcja | GPIO |
|---|---|
| LCD SCLK / MOSI / CS / DC / RST / podświetlenie | 40 / 45 / 42 / 41 / 39 / 5 |
| Dotyk CST328 SDA / SCL / INT / RST | 1 / 3 / 4 / 2 |
| I2S BCLK / LRCK / DOUT | 48 / 38 / 47 |

## Zmiany względem yoRadio_TB

**Konfiguracja i sprzęt**
- `myoptions.h`: `DSP_MODEL DSP_ST7789` z pinami płytki; dla tej płytki wyłączone są dotyk XPT2046, enkodery, IR, NeoPixel, karta SD i okładki SD (ich domyślne piny kolidują z płytką).
- Ekran ST7789 na własnych pinach SPI (`TFT_SCLK`/`TFT_MOSI`, `SPI.begin(40, -1, 45, 42)` w `displayST7789.cpp`).
- Biblioteka Adafruit ST7789/ST77xx (1.12.0, MIT) skopiowana do `src/Adafruit_ST7789/` — wersja z rejestru PlatformIO ciągnie bibliotekę `SD`, która przesłania SD frameworka ESP32.
- Nowy sterownik dotyku **CST328** (`src/Touch/CST328/`, na podstawie demo Waveshare) i `TS_MODEL_CST328` w `options.h`; gesty forka działają bez zmian (lewo/prawo – głośność, góra/dół – stacje, stuknięcie – pauza, górny pasek – Preset/FAV).
- `platformio.ini`: domyślne środowisko **`waveshare-s3-lcd28`** (dziedziczy środowisko autora) z `ARDUINO_USB_CDC_ON_BOOT=1` i `ARDUINO_USB_MODE=1` — log yoRadio idzie przez USB-C płytki, a esptool sam resetuje płytkę do wgrywania.

**Ekran 320×240 na ST7789**
- Układ ekranu jak dla ILI9341 320×240 (zegar flip, data, imieniny, VU, logo stacji 72×48, ekran SD_PLAYER w konfiguracji), warunki „320×240” forka obejmują też ST7789.
- Ekran Preset/FAV włączony dla ST7789.
- Domyślna inwersja kolorów dla panelu IPS (`DEFAULT_INVERTDISPLAY`), stosowana w ustawieniach fabrycznych i przy resecie ustawień ekranu.
- `scripts/prepare_spiffs_logos.py` obsługuje `DSP_ST7789` (zestaw logo 320×240).

**Poprawki błędów (dotyczą też innych płytek)**
- Reset ustawień ekranu z WWW zapisuje teraz `flipscreen`/`invertdisplay` w EEPROM (wcześniej ginęły po restarcie).
- Panel WWW: ikona resetu motywu przykrywała ikonę resetu ekranu w sekcji SCREEN — rozsunięte.

**Czego nie ma (na razie)**
- Odtwarzacza z karty SD (świadomie pominięty), pilota IR, enkoderów, RTC PCF85063, pomiaru baterii i obsługi przycisku zasilania.

**Dodatki**
- `docs/obudowa/obudowa.scad` — parametryczny model obudowy 3D (OpenSCAD) do druku dla tej płytki.

## Budowanie i wgrywanie

- PlatformIO z platformą pioarduino 55.03.37 — wymaga **Pythona 3.10–3.13** (3.14 nie jest obsługiwany). Na Windows uruchamiaj `pio` z PowerShella lub cmd, nie z Git Bash/MSYS.
- `pio run -t upload` — firmware (domyślne środowisko `waveshare-s3-lcd28`).
- Pliki panelu WWW i logo: `pio run -t uploadfs`. Uwaga: kasuje to zapisaną sieć Wi-Fi i playlistę. Jeśli wgrywanie przerywa się przy ~94% („The chip stopped responding”), wgraj obraz bez kompresji:
  `python -m esptool --chip esp32s3 --port COMx write-flash --no-compress 0xC10000 .pio/build/waveshare-s3-lcd28/spiffs.bin`
- Pojedynczy plik strony można wgrać bez kasowania danych: `curl -F "data=@data/www/<plik>;filename=<plik>" http://<ip-radia>/webboard`.
- Po pierwszym uruchomieniu w panelu WWW włącz inwersję kolorów, jeśli ekran ma białe tło (nowa konfiguracja robi to sama).

---

# yoRadio – Tomasz Bunio fork

Modyfikacje projektu yoRadio autorstwa [e2002](https://github.com/e2002/yoradio)
i [VaraiTamas](https://github.com/VaraiTamas/yoRadio) wprowadzone przez autora yoRadio_TB (dokumentacja poniżej pochodzi z oryginalnego forka).

## Moje zmiany: v8.8.2_TB

- Dodano obsługę wyświetlacza ILI9341 320×240.
---

## Moje zmiany: v8.8.1_TB

- Dodano obsługę ulubionych stacji FAV za pomocą pilota na ekranie Preset.
- Dodano import i eksport kopii pamięci FAV w edytorze playlisty WWW.
- Dodano pamiętanie ostatnio odtwarzanego utworu SD oraz opcjonalne wznowienie od zapisanej pozycji.
- Pozycja utworu SD i czas odtwarzania są zapisywane w EEPROM.
- Poprawiono obsługę pauzy, odświeżanie ekranu i dekodowanie okładek w trybie SD_PLAYER.
- Ograniczono przerwy w odtwarzaniu podczas ładowania panelu WWW.

### Pamięć ostatniego utworu SD

Zachowanie odtwarzacza SD można skonfigurować w pliku `myoptions.h`:

- `#define SD_REMEMBER_LAST_TRACK` – po ponownym uruchomieniu trybu SD wybiera ostatnio odtwarzany utwór. Po wyłączeniu tej opcji SD rozpoczyna od pierwszego utworu.
- `#define SD_REMEMBER_LAST_POSITION` – zapisuje również pozycję ostatniego utworu i wznawia odtwarzanie od tego miejsca. Numer utworu, pozycja pliku i czas są przechowywane w EEPROM, dlatego pozostają zapamiętane po restarcie lub odłączeniu zasilania.

Po wybraniu innego utworu zapamiętana pozycja zostaje skasowana. Pozwala to używać pamiętania ostatniego utworu bez wznawiania pozycji, a w przypadku audiobooków włączyć obie opcje.

### Obsługa FAV z pilota

Funkcja jest dostępna na ekranie Preset dla wyświetlacza ILI9488. Każda karta FAV zawiera osiem numerowanych pól pamięci.

1. Naciśnij `HOME`, aby otworzyć ekran Preset.
2. Klawiszami `PREV` i `NEXT` wybierz kartę FAV.
3. Klawiszami `UP` i `DOWN` wybierz na górnym pasku funkcję `Otwórz`, `Zapisz` albo `Usuń`. Aktywna funkcja jest podświetlona na niebiesko.
4. Naciśnij cyfrę od `1` do `8`, aby wskazać pole pamięci. Wybrane pole zostanie podświetlone:
   - jaśniejszym niebieskim dla funkcji `Otwórz`,
   - zielonym dla funkcji `Zapisz`,
   - czerwonym dla funkcji `Usuń`.
5. Naciśnij `PLAY`, aby wykonać wybraną operację.

Klawisz `BACK` anuluje wybór funkcji lub pola. Zapis umieszcza w wybranym polu aktualnie odtwarzaną stację radiową.

---

## Moje zmiany: v8.8_TB

- Sortowanie playlisty SD alfabetycznie zamiast kolejności FAT, co umożliwia poprawną numerację albumów.
- Oprogramowanie posiada wbudowane domyślne przypisania przycisków pilota (czytaj [konfiguracja_IR.md](konfiguracja_IR.md)) oraz obsługuje wybudzanie ESP32 z soft standby (`IR_PIN` GPIO 2).
- Dodano zmianę czcionki zegara dotykiem obszaru minut oraz umożliwiono przełączanie trybu SD/Radio dotykiem obszaru sekund zegara na ekranie PLAYER.
- Dodano dedykowany ekran SD_PLAYER dla odtwarzania z karty SD, z paskiem postępu i sterowaniem.
- Naprawiono auto-play.
- Obsługa NeoPixel i Clock przez WWW.
- Dodano pobieranie okładki z Last.fm, gdy nie uda się jej zdekodować z pliku MP3.
- Dodano wizualizację FFT do odtwarzacza dla trybu noTouch.
- Dodatkowo kilkadziesiąt optymalizacji w zakresie szybkości wyświetlania.

---

## Moje zmiany: v8.7.1_TB

- poprawienie błędów z v8.7
- możliwość zmiany bootlogo, czytaj [convert_bootlogo.md](convert_bootlogo.md)

---

## Moje zmiany: v0.8.7_TB - testowałem tylko na lcd ILI9488.

- Flip clock
- logo stacji radiowych zamiast pogody i bitrate
- automatyczna zmiana czasu z wykorzystaniem TIMEZONE_POSIX
- upłynnienie scrollingu title (co 3px zamiast co 7px).

### Konwerter logo stacji (`convert_logos.bat`)

- konwertuje wszystkie pliki `.png` z katalogu `data/` do binarnego formatu RGB565 (little-endian, 120×90 px)
- pliki `.raw` zapisywane są bezpośrednio do `data/www/`
- aby logo się wczytało, uploadujemy pliki `.raw` przez webboard (Settings → BOARD); nazwa pliku musi być identyczna z nazwą stacji wyświetlaną na górze ekranu
- wymaga biblioteki Pillow: `pip install Pillow`

---

## Moje zmiany: v0.8.6_TB

- Podświetlenie stacji na playliście
- Obsługa diod adresowanych WS2812B
- Timer ON/OFF sterowany przez www
- Wybór czcionki zegara przez www
- Zmiana kolorów (themes) przez www
- Odczyt nazwy stacji z playlisty
- Sleep z dwukliku enkodera

## Oryginalna dokumentacja:

https://github.com/VaraiTamas/yoRadio

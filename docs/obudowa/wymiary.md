# Wymiary ESP32-S3-Touch-LCD-2.8 (pod obudowę)

Źródło: rysunek 2D Waveshare (https://files.waveshare.com/wiki/ESP32-S3-Touch-LCD-2.8/ESP32-S3-Touch-LCD-2.8%202D.pdf)
oraz model 3D `esp32-s3-touch-lcd-2_8.stp` (Creo, 07.2024) — pobrane poza repozytorium.
Rysunek jest w pionie; wymiary w mm.

## Przód (szkło dotyku)
- Obrys szkła: 50,54 × 73,06 (±0,05), narożniki R2.
- Obszar widoczny dotyku (TP VA): 43,80 × 58,20 (±0,15).
- Aktywny obszar LCD (AA): 43,20 × 57,60.
- Ramka wokół TP VA: boki po 3,37; krawędź od strony USB-C 10,43; przeciwna ok. 4,43.

## Grubość
- Całość: 10,0 (od szkła do najwyższego elementu z tyłu).
- Szkło + LCD: 3,6 (w tym szkło 0,7).
- Płytka z elementami: ok. 6,0.

## Płytka (tył)
- PCB: 49,90 × 69,00; górna krawędź PCB 1,9 poniżej krawędzi szkła (od strony przeciwnej do USB-C).
- 4 otwory Ø2,5 (M2), rozstaw 41,00 × 60,00, środki 4,50 od krawędzi PCB.

## Złącza (widok z tyłu, w pionie, USB-C na dole)
- Dolna krawędź: UART | USB-C | I2C. Od środka lewego dolnego otworu: 9,00 do pierwszego złącza, +11,6 do USB-C, +11,4 do trzeciego.
- Lewa krawędź: przyciski BOOT, RESET, BAT_PWR — od środka górnego otworu 7,84, potem co 7,82; dalej +10,86 do środka gniazda microSD (karta wsuwa się z boku).
- Prawa krawędź: głośnik (4 pin), RTC, BAT (MX1.25 2 pin), pokrętło głośności.
- Góra: złącze IPEX (antena zewnętrzna).
- Szeroka ramka ekranu (10,43) jest od strony USB-C.

## Obudowa — `obudowa.scad` (OpenSCAD, parametryczna)

Zewnętrznie ok. 164 × 70 × 40 mm, front pochylony o 12°. Ekran poziomo, **przyciski u góry**
(w firmware: `flipscreen = true`, `fliptouch = false`). Patrząc od przodu USB-C jest na prawym boku modułu.

Pliki do druku (Bambu A1 mini, PLA/PETG, ścianki 2,4 mm, bez podpór):

| Plik | Ułożenie na stole | Szt. |
|---|---|---|
| `obudowa_front.stl` | twarzą do stołu (tak jak w pliku) | 1 |
| `obudowa_back.stl` | zewnętrzną stroną do stołu | 1 |
| `obudowa_clamp.stl` | listwą do stołu, kołkami do góry | 2 |
| `obudowa_button.stl` | kołnierzem do stołu (3 popychacze w pliku) | 1 (=3 szt.) |

Model: `obudowa.scad` (ten katalog); podglądy: `podglad_*.png`, `wnetrze_*.png`, `popychacze*.png`, `przekroj_przycisk.png`, `wciecie_kabla.png`. Ponowne generowanie: `openscad -o obudowa_front.stl -D 'part="front"' obudowa.scad` (oraz `back`, `clamp`, `button`;
`assembly` = podgląd złożenia, `section` + `section_x` = przekrój kontrolny).

Montaż:
- Głośniki (owal 20 × 30 × 4) przyklejone piankowym pierścieniem od środka do frontu, w ranteczkach,
  języczkiem z przewodem w dół. Wiązka (wtyk wspólny dla obu głośników) kładziona od tyłu we wcięcia
  4 × 3 mm u dołu tylnej krawędzi ścianek działowych → po ułożeniu zalać klejem na gorąco.
- Popychacze przycisków włożyć od środka w otwory górnej ścianki i przytrzymać taśmą od zewnątrz,
  dopóki moduł nie zostanie przykręcony (popychacz wsunięty do środka zablokuje wsuwanie modułu).
- Moduł wkładany od tyłu szkłem w ramkę z żeberek. Z tyłu PCB w 4 otworach są przylutowane tulejki
  SMTSO-M2.5-4ET (wys. 4 mm). Moduł **nie jest przykręcany**: dwie listwy dociskają czoła tulejek podkładkami,
  kołki Ø1,6 wchodzą w otwory tulejek i ustalają moduł. Każda listwa przykręcona 2 wkrętami M3×6–8 w słupki
  (otwory pilotowe Ø2,6, wkręty wkręcane w plastik); listwa ugina się o ok. 0,3 mm i dociska szkło do frontu.
  Jeśli moduł grzechocze — podłożyć 0,5 mm pianki pod podkładki albo zwiększyć `clamp_preload`.
  Przy druku listew włączyć minimalny czas warstwy (małe kołki) lub drukować obie naraz.
- Pokrywa: 4 wkręty M3×10 w słupki w narożnikach komór. Na krawędzie komór (styk z pokrywą)
  nakleić cienką piankę/filc — komory głośników muszą być szczelne.
- USB-C: kabel z wtykiem kątowym (90°, przewód prostopadle do płytki) wyprowadzony przez otwór w pokrywie.
  Prosty wtyk się nie zmieści (między modułem a komorą jest ok. 15 mm).
- Przyciski BOOT/RESET/PWR (TS24CA, boczne): popychacze Ø3,0 w otworach Ø3,4, wystają 2 mm, luz do trzpienia ok. 0,4 mm.
  Kolejność sprawdzić na płytce.
- Do zrobienia przy akumulatorze: miejsce w podstawie za modułem, przycisk PWR do przeprojektowania.

Wszystkie wkręty: M3 (4× M3×6–8 do listew, 4× M3×10 do pokrywy).

Geometria sprawdzona z modelem STEP Waveshare (pozycje przycisków, tulejek, wysokości złączy pod listwami).
Niezweryfikowane na wydruku: pasowanie szkła (luz 0,3), docisk listew i pasowanie kołków w tulejkach, pasowanie trzonów popychaczy w poziomych
otworach Ø3,4 i czy przyciski klikają.

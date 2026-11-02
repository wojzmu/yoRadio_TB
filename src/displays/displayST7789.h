#ifndef displayST7789_h
#define displayST7789_h

#include "Arduino.h"
#include <Adafruit_GFX.h>
#include "../Adafruit_ST7789/Adafruit_ST7789.h"

#if DSP_MODEL==DSP_ST7789_76
  #include "fonts/bootlogo62x40.h"
  #include "fonts/dsfont35.h"
#else
  #include "fonts/bootlogo54x54.h"
  #include "fonts/dsfont52.h"
#endif

typedef GFXcanvas16 Canvas;
typedef Adafruit_ST7789 yoDisplay;

// Rozmiar zgodny z zestawem logos_raw/320x240 (prepare_spiffs_logos.py), jak w ILI9341.
#ifndef STATION_LOGO_W
  #define STATION_LOGO_W 72
#endif
#ifndef STATION_LOGO_H
  #define STATION_LOGO_H 48
#endif

#include "tools/commongfx.h"

#if __has_include("conf/displayST7789conf_custom.h")
  #include "conf/displayST7789conf_custom.h"
#else
  #if DSP_MODEL==DSP_ST7789
    #include "conf/displayST7789conf.h"
  #endif
#endif

#endif

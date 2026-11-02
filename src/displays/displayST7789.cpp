//v0.9.720
#include "../core/options.h"
#if DSP_MODEL==DSP_ST7789 || DSP_MODEL==DSP_ST7789_240 || DSP_MODEL==DSP_ST7789_76 || DSP_MODEL==DSP_ST7789_170
#include "dspcore.h"
#include "../core/config.h"

#if DSP_HSPI
DspCore::DspCore(): Adafruit_ST7789(&SPI2, TFT_CS, TFT_DC, TFT_RST) {}
#else
DspCore::DspCore(): Adafruit_ST7789(TFT_CS, TFT_DC, TFT_RST) {}
#endif

void DspCore::initDisplay() {
#if !DSP_HSPI && defined(TFT_SCLK) && defined(TFT_MOSI)
  // Ekran na niestandardowych pinach SPI (np. Waveshare ESP32-S3-Touch-LCD-2.8).
  // Adafruit wywołuje później SPI.begin() bez pinów – na ESP32 to no-op, bo magistrala już działa.
  SPI.begin(TFT_SCLK, -1, TFT_MOSI, TFT_CS);
#endif
  if(DSP_MODEL==DSP_ST7789_76){
    init(76,284);
  }else if(DSP_MODEL==DSP_ST7789_170){
    init(170,320);
  }else{
    init(240,(DSP_MODEL==DSP_ST7789)?320:240);
  }
  invert();
  cp437(true);
  flip();
  setTextWrap(false);
  setTextSize(1);
  fillScreen(0x0000);
}

void DspCore::clearDsp(bool black){ fillScreen(black?0:config.theme.background); }
void DspCore::flip(){
#if DSP_MODEL==DSP_ST7789 || DSP_MODEL==DSP_ST7789_76 || DSP_MODEL==DSP_ST7789_170
  setRotation(config.store.flipscreen?3:1);
#endif
#if DSP_MODEL==DSP_ST7789_240
  if(ROTATE_90){
    setRotation(config.store.flipscreen?3:1);
  }else{
    setRotation(config.store.flipscreen?2:0);
  }
#endif
}
void DspCore::invert(){ invertDisplay(
#if DSP_MODEL==DSP_ST7789_170
!
#endif
config.store.invertdisplay); }
void DspCore::sleep(void){ enableSleep(true); delay(150); enableDisplay(false); delay(150); }
void DspCore::wake(void){ enableDisplay(true); delay(150); enableSleep(false); delay(150); }

#endif
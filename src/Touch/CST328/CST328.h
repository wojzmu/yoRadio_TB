#include "../../core/options.h"
#if TS_MODEL == TS_MODEL_CST328
#ifndef CST328_h
#define CST328_h
#include <Arduino.h>
#include <Wire.h>

// Port of the Waveshare ESP32-S3-Touch-LCD-2.8 demo driver (Touch_CST328.cpp).
// Registers are 16-bit, high byte first.

#define CST328_ADDR                     0x1A
#define CST328_MAX_POINTS               5

// Normal mode registers
#define CST328_REG_XY                   0xD000  // point data (status, X/Y, pressure, ...)
#define CST328_REG_NUMBER               0xD005  // low nibble = finger count; write 0 to clear

// Debug info registers (valid in debug info mode)
#define CST328_REG_INFO_TP_NTX          0xD1F4  // 24 bytes block: D1F4..D20B
#define CST328_REG_INFO_RES_X           0xD1F8
#define CST328_REG_INFO_RES_Y           0xD1FA
#define CST328_REG_INFO_BOOT_TIME       0xD1FC  // demo reads 4 bytes here: X max (LE), Y max (LE)
#define CST328_REG_INFO_PROJECT_ID      0xD200
#define CST328_REG_INFO_IC_TYPE         0xD202
#define CST328_REG_INFO_FW_VERSION      0xD204
#define CST328_REG_INFO_IC_CHECKSUM     0xD208

// Work modes
#define CST328_REG_MODE_DEBUG_INFO      0xD101
#define CST328_REG_MODE_NORMAL          0xD109

#define CST328_ID_MAGIC                 0xCACA  // bytes 10..11 of the 0xD1F4 block (LE)

class CST328
{
public:
	CST328(TwoWire *wire, int8_t intPin = -1, int8_t rstPin = -1, uint8_t addr = CST328_ADDR);
	bool begin();
	bool read();
	bool touched() const { return _touched; }

	uint8_t  points = 0;    // fingers from last read() (0..5)
	uint16_t x = 0, y = 0;  // raw coordinates of the first finger

private:
	bool readReg(uint16_t reg, uint8_t *buf, uint8_t len);
	bool writeReg(uint16_t reg, const uint8_t *buf, uint8_t len);
	void hwReset();

	TwoWire *_wire = nullptr;
	int8_t   _intPin;
	int8_t   _rstPin;
	uint8_t  _addr;
	bool     _touched = false;
};
#endif
#endif

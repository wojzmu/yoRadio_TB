#include "../../core/options.h"
#if TS_MODEL == TS_MODEL_CST328
#include "CST328.h"

CST328::CST328(TwoWire *wire, int8_t intPin, int8_t rstPin, uint8_t addr)
	: _wire(wire), _intPin(intPin), _rstPin(rstPin), _addr(addr) {}

bool CST328::readReg(uint16_t reg, uint8_t *buf, uint8_t len)
{
	_wire->beginTransmission(_addr);
	_wire->write((uint8_t)(reg >> 8));
	_wire->write((uint8_t)(reg & 0xFF));
	if (_wire->endTransmission(true) != 0) return false;
	if (_wire->requestFrom(_addr, len) != len) return false;
	for (uint8_t i = 0; i < len; i++) buf[i] = _wire->read();
	return true;
}

bool CST328::writeReg(uint16_t reg, const uint8_t *buf, uint8_t len)
{
	_wire->beginTransmission(_addr);
	_wire->write((uint8_t)(reg >> 8));
	_wire->write((uint8_t)(reg & 0xFF));
	for (uint8_t i = 0; i < len; i++) _wire->write(buf[i]);
	return _wire->endTransmission(true) == 0;
}

void CST328::hwReset()
{
	if (_rstPin < 0) return;
	pinMode(_rstPin, OUTPUT);
	digitalWrite(_rstPin, HIGH);
	delay(50);
	digitalWrite(_rstPin, LOW);
	delay(5);
	digitalWrite(_rstPin, HIGH);
	delay(50);
}

bool CST328::begin()
{
	if (_intPin >= 0) pinMode(_intPin, INPUT);
	hwReset();

	uint8_t buf[24] = {0};
	// enter debug info mode (zero-length write, as in the demo)
	if (!writeReg(CST328_REG_MODE_DEBUG_INFO, buf, 0)) {
		Serial.printf("[CST328] no ACK from 0x%02X\n", _addr);
		return false;
	}
	if (readReg(CST328_REG_INFO_BOOT_TIME, buf, 4)) {
		Serial.printf("[CST328] ID: %02X %02X %02X %02X, X_MAX=%u Y_MAX=%u\n",
			buf[0], buf[1], buf[2], buf[3],
			(unsigned)(buf[1] * 256 + buf[0]), (unsigned)(buf[3] * 256 + buf[2]));
	}
	if (readReg(CST328_REG_INFO_TP_NTX, buf, 24)) {
		uint16_t magic = ((uint16_t)buf[11] << 8) | buf[10];
		Serial.printf("[CST328] magic=0x%04X (%s) res=%ux%u fw=%02X%02X%02X%02X\n",
			magic, magic == CST328_ID_MAGIC ? "ok" : "unexpected",
			(unsigned)(buf[5] * 256 + buf[4]), (unsigned)(buf[7] * 256 + buf[6]),
			buf[16], buf[17], buf[18], buf[19]);
	}
	// back to normal (report) mode
	if (!writeReg(CST328_REG_MODE_NORMAL, buf, 0)) {
		Serial.println("[CST328] failed to enter normal mode");
		return false;
	}
	Serial.println("[CST328] init ok");
	return true;
}

bool CST328::read()
{
	uint8_t cnt = 0;
	const uint8_t clr = 0;
	if (!readReg(CST328_REG_NUMBER, &cnt, 1)) {
		points = 0; _touched = false;
		return false;
	}
	cnt &= 0x0F;
	if (cnt == 0 || cnt > CST328_MAX_POINTS) {
		writeReg(CST328_REG_NUMBER, &clr, 1);
		points = 0; _touched = false;
		return true;
	}
	// d[0]=0xD000 status, d[1]=X hi, d[2]=Y hi, d[3]=X lo nibble<<4 | Y lo nibble, d[4]=pressure
	uint8_t d[5];
	bool ok = readReg(CST328_REG_XY, d, 5);
	writeReg(CST328_REG_NUMBER, &clr, 1);  // clear status like the demo
	if (!ok) {
		points = 0; _touched = false;
		return false;
	}
	points = cnt;
	x = (uint16_t)(((uint16_t)d[1] << 4) | (d[3] >> 4));
	y = (uint16_t)(((uint16_t)d[2] << 4) | (d[3] & 0x0F));
	_touched = true;
	return true;
}
#endif

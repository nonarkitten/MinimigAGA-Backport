/*
Copyright 2021 Paul Honig

This file is part of Minimig

Minimig is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Minimig is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

This is the Minimig I2C handler.

2021-03-16 - Start implementation memory mapped I2C driver.

*/

#include "i2c.h"

void i2c_set_divider(unsigned short div) {
  I2C(HW_I2C_DIVIDER)=div;
}

void i2c_set_address(unsigned short addr) {
  unsigned short lo = (addr & 0xff);
  unsigned short hi = (addr>>8) & 0xff;

  //I2C(HW_I2C_DATA)=CMD_I2C_SET_SCL_L+lo;
  //I2C(HW_I2C_DATA)=CMD_I2C_SET_SCL_H+hi;
  (*(volatile unsigned short *)(I2C_BASE))=CMD_I2C_SET_SCL_L+lo;
  (*(volatile unsigned short *)(I2C_BASE))=CMD_I2C_SET_SCL_H+hi;
}

void i2c_start() {
  I2C(HW_I2C_DATA)=CMD_I2C_START;
}

void i2c_stop() {
  I2C(HW_I2C_DATA)=CMD_I2C_STOP;
}

void i2c_write(unsigned char byte) {
  I2C(HW_I2C_DATA)=CMD_I2C_WRITE+(unsigned short)byte;
}

// Be aware, the send buffer is only 8 bytes!
void i2c_write_multi(unsigned char *byte, unsigned char size) {
  for (unsigned char pos=0; pos<size; pos++) {
    if (pos+1 == size) {
      // last byte
      I2C(HW_I2C_DATA)=CMD_I2C_WRITEMULTI + CMD_I2C_LAST_BYTE + (unsigned short) *(byte+pos);
    } else {
      I2C(HW_I2C_DATA)=CMD_I2C_WRITEMULTI + (unsigned short) *(byte+pos);
    }
  }
}

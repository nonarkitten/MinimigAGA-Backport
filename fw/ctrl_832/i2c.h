#ifndef I2C_H_INCLUDED
#define I2C_H_INCLUDED

/*
 * I2C functionality
 */
// Base memory address
#define I2C_BASE 0x0fffff60

// Memory offsets
#define HW_I2C_DATA         0x00000000 // Short pointer, 2bytes, per 4 bytes, so +2 per register.
#define HW_I2C_STATUS       0x00000002
#define HW_I2C_DIVIDER      0x00000004
#define HV_I2C_ID           0x00000006   

// Commands
#define CMD_I2C_WRITE       0x02
#define CMD_I2C_WRITEMULTI  0x03
#define CMD_I2C_START       0x04
#define CMD_I2C_STOP        0x05
#define CMD_I2C_SET_ADDR    0x0b
#define CMD_I2C_SET_SCL_L   0x0c
#define CMD_I2C_SET_SCL_H   0x0d

#define CMD_I2C_LAST_BYTE   0x10

#define HW_I2C(x) (*(volatile unsigned short *)(I2C_BASE+x))
#define I2C(x) (HW_I2C(x))

void i2c_set_divider(unsigned short div);
void i2c_set_address(unsigned short addr);
void i2c_start();
void i2c_stop();
void i2c_write(unsigned char byte);
void i2c_write_multi(unsigned char *byte, unsigned char size);

#endif


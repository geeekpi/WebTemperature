#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include "math.h"

void main()
{
	int file;
	char *bus = "/dev/i2c-1";
	if ((file = open(bus, O_RDWR)) <0)
	{
		printf("Failed to open the but.");
		exit(1);
	}

	ioctl(file, I2C_SLAVE, 0x48);

	char config[3] = {0};
	config[0] = 0x01;
	//config[1] = 0xD4;
	config[1] = 0xC5;
	config[2] = 0x84;
 	write(file, config, 3);
	sleep(1);

	char reg[1] = {0x00};
	write(file, reg, 1);
	char data[2] = {0};
	if(read(file, data, 2) != 2)
	{
		printf("Error: Input/Output Error!");
	}
	else
	{
		int raw_adc = (data[0] * 256 + data[1]);
		if( raw_adc > 32767 )
		{
			raw_adc -= 65535;
		}
		float result = (3.3 - raw_adc * 2.048 /32768 * 2 ) / (raw_adc * 2.048 / 32768 * 2 / 20) * 1000;
		float temp = (float)(1/(log10f(result/10000.0)/3470.0 + 1/(25.0+273.15))-273.15+0.5);
		printf("%02f\n", temp);
	}
}

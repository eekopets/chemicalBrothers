#ifndef ads12xx_H
#define ads12xx_H
#endif
//#define ADS1248
#define ADS1256
//#define ADS1258

/*Serial Template */


#include "ads1256.h"




#include "SPI.h"
void _DRDY_Interuppt();
void waitforDRDY();

class ads12xx {
public:
	ads12xx();
	void begin(
		int CS,
		int START,
		int DRDY
		);

	void Reset(
		
		);

	unsigned long  GetRegisterValue(
		uint8_t regAdress
		);
	
	void SendCMD(
		uint8_t cmd
		);

	void SetRegisterValue(
		uint8_t regAdress,
		uint8_t regValue
		);

	struct regValues_t
	{

		uint8_t STATUS_val = STATUS_RESET;
		uint8_t MUX_val = MUX_RESET;
		uint8_t ADCON_val = ADCON_RESET;
		uint8_t DRATE_val = DRATE_RESET;
		uint8_t IO_val = IO_RESET;

	};

	long readSingle(
		regValues_t regValues
		);

	float  GetConversion(
		);
		void GetConversion1258(
		uint8_t *statusByte, int32_t *regData
		);
	void calibration(
		int cal_cmd
		);
	void SetRegister(
		regValues_t regValues
		);

private:
	int _CS;
	int _DRDY;
	int _START;
	volatile int DRDY_state;
};

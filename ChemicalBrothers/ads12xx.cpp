#include "ads12xx.h"

//File myFile;
volatile int DRDY_state = HIGH;

// Waits until DRDY Pin is falling (see Interrupt setup). 
// Some commands like WREG, RREG need the DRDY to be low.
void waitforDRDY() {
	while(DRDY_state) {		
	}
	noInterrupts();
	DRDY_state = HIGH;
	interrupts();
}

//Interrupt function
void DRDY_Interuppt() {
	DRDY_state = LOW;
}


// ads12xx setup
ads12xx::ads12xx() {}

void ads12xx::begin(int CS, int START, int DRDY) {
	pinMode(CS, OUTPUT);              // set the slaveSelectPin as an output:
	digitalWrite(CS, HIGH);           // CS HIGH = nothing selected

	SPI.begin();

	pinMode(DRDY, INPUT);             // DRDY read
	pinMode(START, OUTPUT);
	digitalWrite(START, LOW);        // HIGH = Start Convert Continuously
	delay(500);
	//digitalWrite(START, HIGH);
 
 
	_CS = CS;
	_DRDY = DRDY;
	delay(500);
//	SPI.begin();

	attachInterrupt(digitalPinToInterrupt(_DRDY), DRDY_Interuppt, FALLING); //Interrupt setup for DRDY detection ARDUINO

	DRDY_state = digitalRead(_DRDY);
	delay(500);

	// interal VREF einschalten
}


// function to get a 3byte conversion result 
/*long ads12xx::GetConversion() { //long
	double regData; //long
	uint8_t byte0;
	uint8_t byte1;
	uint8_t byte2;
  
	waitforDRDY(); // Wait until DRDY is LOW

	SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1)); 

	digitalWrite(_CS, LOW); //Pull SS Low to Enable Communications
	delayMicroseconds(10); // RD: Wait 25ns to get ready
	SPI.transfer(RDATA); //Issue RDATA

	SPI.transfer(NOP);
	byte0=SPI.transfer(NOP); 
	byte1=SPI.transfer(NOP);
	byte2=SPI.transfer(NOP);
	
	regData = ((((long)byte0<<24) | ((long)byte1<<16) | ((long)byte2<<8)) >> 8); //as data from ADC comes in twos complement LONG

 

 
  //double volt = (regData * 5.00000000)/8388608.00000000;

  //delayMicroseconds(10);
	digitalWrite(_CS, HIGH);

	SPI.endTransaction();

	return regData;
}
*/

float ads12xx::GetConversion() {
  
  int32_t regData;
  waitforDRDY(); // Wait until DRDY is LOW
  SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1));
  digitalWrite(_CS, LOW); //Pull SS Low to Enable Communications with ADS1247
  delayMicroseconds(10); // RD: Wait 25ns for ADC12xx to get ready
  SPI.transfer(RDATA); //Issue RDATA
  delayMicroseconds(10);
  regData |= SPI.transfer(NOP);
  //delayMicroseconds(10);
  regData <<= 8;
  regData |= SPI.transfer(NOP);
  //delayMicroseconds(10);
  regData <<= 8;
  regData |= SPI.transfer(NOP);
  delayMicroseconds(10);
  digitalWrite(_CS, HIGH);
  SPI.endTransaction();

  if (long minus = regData >> 23 == 1) 
  {
    regData = regData - 16777216;  //for the negative sign
  }

  float voltage = (5.1 / 8388608)*regData;
 //Serial.print(voltage,8);
  return  voltage;
 
}

//------------------------------------------------------------------
//cycling through all the 8 channels
/*long ads12xx::GetMuxConversion() {
  int32_t regData;
  waitforDRDY(); // Wait until DRDY is LOW
  SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1));
  digitalWrite(_CS, LOW); //Pull SS Low to Enable Communications with ADS1247
  delayMicroseconds(10); // RD: Wait 25ns for ADC12xx to get ready


  
  SPI.transfer(RDATA); //Issue RDATA
  delayMicroseconds(10);
  regData |= SPI.transfer(NOP);
  //delayMicroseconds(10);
  regData <<= 8;
  regData |= SPI.transfer(NOP);
  //delayMicroseconds(10);
  regData <<= 8;
  regData |= SPI.transfer(NOP);
  delayMicroseconds(10);
  digitalWrite(_CS, HIGH);
  SPI.endTransaction();

  //double voltage = (5.1 / 8388608)*regData;
  //Serial.println(voltage,8);

  return regData;
}

//------------------------------------------------------------------

*/

// function to write a register value to the adc
// argumen: adress for the register to write into, value to write
void ads12xx::SetRegisterValue(uint8_t regAdress, uint8_t regValue) {
	uint8_t regValuePre = ads12xx::GetRegisterValue(regAdress);
	if (regValue != regValuePre) {
		//digitalWrite(_START, HIGH);
		delayMicroseconds(10);
		waitforDRDY();

		SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1)); // initialize SPI with SPI_SPEED, MSB first, SPI Mode1

		digitalWrite(_CS, LOW);
		delayMicroseconds(10);
		SPI.transfer(WREG | regAdress); // send 1st command byte, address of the register

		SPI.transfer(0x00);		// send 2nd command byte, write only one register

		SPI.transfer(regValue);         // write data (1 Byte) for the register
		delayMicroseconds(10);
		digitalWrite(_CS, HIGH);
		//digitalWrite(_START, LOW);  //commented out temporarily
		//if (regValue != ads12xx::GetRegisterValue(regAdress)) {   //Check if write was succesfull
		//	Serial.print("Write to Register 0x");
		//	Serial.print(regAdress, HEX);
		//	Serial.println(" failed!");
		//}

		SPI.endTransaction();

		
	}

}
//function to read a register value from the adc
//argument: adress for the register to read
//To do: implement multiple register read for ADS1258
unsigned long ads12xx::GetRegisterValue(uint8_t regAdress) {
	//digitalWrite(_START, HIGH);
	waitforDRDY(); //wait for data ready go low

	SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1)); // initialize SPI with 4Mhz clock, MSB first, SPI Mode1

	uint8_t bufr;
 
	digitalWrite(_CS, LOW); //set CS low
	delayMicroseconds(10); //wait
	SPI.transfer(RREG | regAdress); // send 1st command byte, address of the register 
    //reading a register:0001rrrr r:address of the register
	SPI.transfer(0x00);			// send 2nd command byte, read only one register
    //all zeros
	delayMicroseconds(10);
	bufr = SPI.transfer(NOP);	// read data of the register
	delayMicroseconds(10);
	digitalWrite(_CS, HIGH);

	SPI.endTransaction();

	return bufr;
}


//Sends a Command to the ADC
//Like SELFCAL, GAIN, SYNC, WAKEUP

void ads12xx::SendCMD(uint8_t cmd) {
	waitforDRDY();

	SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1)); // initialize SPI with 4Mhz clock, MSB first, SPI Mode0

	digitalWrite(_CS, LOW);
	delayMicroseconds(10);
	SPI.transfer(cmd);
	delayMicroseconds(10);
	digitalWrite(_CS, HIGH);

	SPI.endTransaction();

}


// function to reset the adc
void ads12xx::Reset() {

	SPI.beginTransaction(SPISettings(SPI_SPEED, MSBFIRST, SPI_MODE1)); // initialize SPI with  clock, MSB first, SPI Mode1

	digitalWrite(_CS, LOW);
	delayMicroseconds(10);
	SPI.transfer(RESET); //Reset
	delay(2); //Minimum 0.6ms required for Reset to finish.
	SPI.transfer(SDATAC); //Issue SDATAC
	delayMicroseconds(100);
	digitalWrite(_CS, HIGH);

	SPI.endTransaction();

}

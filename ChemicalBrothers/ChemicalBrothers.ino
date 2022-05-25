
#include <SPI.h>
#include "ads12xx.h"
#include <SD.h>

File myFile;
const int  START = 8;
const int  CS = 10;
const int  DRDY = 2;
const int RESET_ = 9;

const int SDpin = 53;//slave select SD-card
int Cells = 8;
char Bin[] = {B00001000, B00011000, B00101000,  B00111000, B01001000, B01011000, B01101000, B01111000};
int PinMotors[] = {46, 44, 8, 45 , 3, 4 , 6, 7};
int PinMotors2[] = {48, 42, 47, 43, 40, 5, 41, 37};
int PinsPhotoInt[] = {22, 24, 23, 25, 9, 11, 12, 13};
int interState[] = {0, 0, 0, 0, 0, 0, 0, 0};
int current[] = {0, 0, 0, 0, 0, 0, 0, 0};
bool flag[] = {0, 0, 0, 0, 0, 0, 0, 0};
int periods[] = {3000, 6000, 9000, 12000, 15000, 18000, 21000, 24000};

int MotorsSpeed[] = {18, 18, 18, 18, 18, 18, 18, 18};
int CalibrationTime = 10000;
ads12xx ADS;  //initialize ADS as object of the ads12xx class


void setup()
{
  //double startTime = millis();
  Serial.begin(115200);
  Serial.println("ADS1256");
  Serial.print("Initializing SD card...");
  pinMode(10, OUTPUT);

  if (!SD.begin(SDpin)) {

    Serial.println("initialization failed!");
    while (1);
  }
  else
  {
    Serial.println("done!");
  }
  ADS.begin(CS, START, DRDY);  //initialize ADS as object of the ads12xx class
  ADS.Reset(); //Reset the AD chip. Every time you see the message on the Serial Terminal, everything is set to default!
  delay(10);
  ADS.SetRegisterValue(STATUS, B00110100);  //Autocal is ON
  ADS.SetRegisterValue(MUX, B00001000);
  ADS.SetRegisterValue(ADCON, B0000000);// gain PGA
  ADS.SetRegisterValue(DRATE, B01100011);  // 50 SPS
  ADS.SetRegisterValue(DRATE, B10100001);  // 50 SPS
  ADS.SetRegisterValue(IO, B11101111);
  ADS.SendCMD(SELFCAL);
  Serial.println("Press 'i' for information about options");
  for (int i = 0; i < Cells; i++)
  {
    analogWrite(PinMotors2[i], 0);
  }
}
void StartMotors()
{
  Serial.println("Start motors!");
  for (int i = 0; i < Cells; i++)
  {
    analogWrite(PinMotors[i], MotorsSpeed[i]);
  }
}

void StopMotors()
{
  Serial.println("Stop motors!");
  for (int i = 0; i < Cells; i++)
  {
    analogWrite(PinMotors[i], 0);
  }
}
void Info()
{
  Serial.println("'w'— starts writing to file");
  Serial.println("'s'— stops writing to file");
  Serial.println("'m'— start motors");
  Serial.println("'n'— stop motors");
  Serial.println("'c'— calibration speed");
  Serial.println("'C'— stop calibration");
  for (int i = 0; i < Cells; i++)
  {
    Serial.print("Speed motor:");
    Serial.print(i + 1);
    Serial.print("\t");
    Serial.println(interState[i] / 2);
  }
}

void Calibration()
{
  Serial.println("Calibration speed");
  for (int i = 0; i < Cells; i++)
  {
    current[i] = digitalRead(PinsPhotoInt[i]);
  }
  int startT = millis();
  while ((Serial.read() != 'C') && (millis() - startT < CalibrationTime)) {
    for (int i = 0; i < Cells; i++)
    {
      if (digitalRead(PinsPhotoInt[i]) == !current[i])
      {
        interState[i] = interState[i] + 1;
        current[i] = digitalRead(PinsPhotoInt[i]);
      }
    }
  }
  Serial.println("stop calibration");
  //Serial.println (interState[8]);
}


void rutine()
{

  if (!SD.begin(SDpin))
  {
    Serial.println("No card");
  } else {
    myFile = SD.open("test6.txt", FILE_WRITE);
    Serial.println("Start writing to file.");
    double startTime = millis();
    for (int i = 0; i < Cells; i++)
    {
      analogWrite(PinMotors[i], MotorsSpeed[i]);
      current[i] = startTime;
      flag[i] = true;
    }
    while (Serial.read() != 'p') {

      ADS.SendCMD(SELFCAL);
      ADS.SetRegisterValue(DRATE, B10010010);  // 500 SPS
      double elapsedTime = millis();
      myFile.print(elapsedTime, 2);
      for (int i = 0; i < Cells; i++)
      {
        //Serial.print(current[i] - elapsedTime);
        //Serial.print("\t");
        if ( elapsedTime- current[i] > periods[i])
        {
          flag[i] = !flag[i];

          current[i] = elapsedTime;
        }
        if (flag[i])
          analogWrite(PinMotors[i], MotorsSpeed[i]);

        else
          analogWrite(PinMotors[i], 0);

        myFile.print("\t");
        ADS.SetRegisterValue(MUX, Bin[i]);//AIN0+AINCOM -- CH0
        myFile.print(ADS.GetConversion(), 8);
      }
    }
    myFile.print("\n");
  }
  Serial.println("done writing to file.");
  myFile.close();
}


void loop() {

  if (Serial.available() > 0) {
    char cin = Serial.read();
    switch (cin) {
      case 'w':
        rutine();
        break;
      case 'm':
        StartMotors();
        break;
      case 'n':
        StopMotors();
        break;
      case 'i':
        Info();
        break;
      case 'c':
        Calibration();
        break;

      //-------------------------------------------------------------------------------------------------
      default:

        break;
        //-------------------------------------------------------------------------------------------------
    }


  }
}

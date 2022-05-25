#include "settings.h"

void settings::StartMotors()
{
  Serial.println("Start motors!");
  for (int i = 0; i < Cells; i++)
  {
    analogWrite(PinMotors[i], MotorsSpeed[i]);
  }
}

void settings::StopMotors()
{
  Serial.println("Stop motors!");
  for (int i = 0; i < Cells; i++)
  {
    analogWrite(PinMotors[i], 0);
  }
}
void settings::Info()
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

void settings::Calibration()
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


void settings::rutine()
{

  if (!SD.begin(SDpin))
  {
    Serial.println("No card");
  } else {
    
    File myFile = SD.open("test7.txt", FILE_WRITE);
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
        if (elapsedTime - current[i] > periods[i])
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
      myFile.print("\n");
    }
    Serial.print("done writing to file.");
    Serial.println();
    myFile.close();
  }

}

void settings::Setup()
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

settings::settings() {};

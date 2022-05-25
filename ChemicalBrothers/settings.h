#include <SPI.h>
#include "ads12xx.h"
#include <SD.h>

class settings {
  public:

    static const int Cells = 8;
    const int  START = 8;
    const int  CS = 10;
    const int  DRDY = 2;
    const int RESET_ = 9;

    const int SDpin = 53;//slave select SD-card

    const char Bin[Cells] = {B00001000, B00011000, B00101000, B00111000, B01001000, B01011000, B01101000, B01111000};
    const int PinMotors[Cells] = {46, 44, 8, 45 , 3, 4 , 6, 7};
    const int PinMotors2[Cells] = {48, 42, 47, 43, 40, 5, 41, 37};
    const int PinsPhotoInt[Cells] = {22, 24, 23, 25, 9, 11, 12, 13};
    int interState[Cells] = {0, 0, 0, 0, 0, 0, 0, 0};
    long int current[Cells] = {0, 0, 0, 0, 0, 0, 0, 0};
    bool flag[Cells] = {0, 0, 0, 0, 0, 0, 0, 0};
    const long int periods[Cells] = {3000, 6000, 9000, 12000, 15000, 18000, 21000, 24000};

    const int MotorsSpeed[Cells] = {18, 18, 18, 18, 18, 18, 18, 18};
    const int CalibrationTime = 30000; //30 seconds

    ads12xx ADS;  //initialize ADS as object of the ads12xx class
    //File myFile;

    void settings::StartMotors();
    void settings::StopMotors();
    void settings::Info();
    void settings::Calibration();
    void settings::rutine();
    void settings::Setup();
    settings::settings();
};

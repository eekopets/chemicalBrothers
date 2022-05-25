#include "settings.h"
settings Set;
void setup()
{
   Set.Setup();
}

void loop() {

  if (Serial.available() > 0) {
    char cin = Serial.read();
    switch (cin) {
      case 'w':
        Set.rutine();
        break;
      case 'm':
        Set.StartMotors();
        break;
      case 'n':
        Set.StopMotors();
        break;
      case 'i':
        Set.Info();
        break;
      case 'c':
        Set.Calibration();
        break;

      //-------------------------------------------------------------------------------------------------
      default:

        break;
        //-------------------------------------------------------------------------------------------------
    }


  }
}

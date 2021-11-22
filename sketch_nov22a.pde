#include <WaspSensorAgr_v30.h>
///////////////////////////////1 ///////////////////////
// Variable to store the anemometer value
float anemometer;
// Variable to store the pluviometer value
float pluviometer1; //mm in current hour 
float pluviometer2; //mm in previous hour
float pluviometer3; //mm in last 24 hours
// Variable to store the vane value
int vane;
// variable to store the number of pending pulses
int pendingPulses;
// define node identifier
char nodeID[] = "node_WS";
//Instance object
weatherStationClass weather;
//////////////////////////////// 2 ////////////////////////////
// Instance object
radiationClass radSensor;
// Variable to store the radiation conversion value
float solarRadiation,solarValue;

///////////////////////////////  3 ////////////////////////////////
// Variable to store the read value
float denValue;
/*
 * Define object for sensor: dendSensor
 * Input to choose type of dendrometer. 
 * Possibilities for this sensor:
 *  - SENS_SA_DF
 *  - SENS_SA_DD
 *  - SENS_SA_DC3
 *  - SENS_SA_DC2 (old)
 */
dendrometerClass dendSensor(SENS_SA_DF);

///////////////Input for 4/////////////////////////////////////////
// Variable to store the read value
float temp,humd,pres;


/// Input for  5 /////////////////////////
// Variable to store the read value
float wetValue;
//Instance sensor object
leafWetnessClass lwSensor;

/////////////////// Input for 6 //////////////////////////////////////
// Variable to store the read value
uint16_t dist = 0;



void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Start program"));
  // Turn on the sensor board
  Agriculture.ON(); 

  USB.print(F("Weather Time:"));
  RTC.ON();
  USB.println(RTC.getTime());  
  
}


 
void loop()
{
  ////////////////////////////////////////////////// 1 /////////////////////////////////////////////
  /////////////////////////////////////////////
  // 1. Enter sleep mode
  /////////////////////////////////////////////
  Agriculture.sleepAgr("00:00:00:01", RTC_ABSOLUTE, RTC_ALM1_MODE5, SENSOR_ON, SENS_AGR_PLUVIOMETER);
  
  /////////////////////////////////////////////
  // 2.1. check pluviometer interruption
  /////////////////////////////////////////////
  if( intFlag & PLV_INT)
  {
    USB.println(F("+++ PLV interruption +++"));
    pendingPulses = intArray[PLV_POS];
    USB.print(F("Number of pending pulses:"));
    USB.println( pendingPulses );
    for(int i=0 ; i<pendingPulses; i++)
    {
      // Enter pulse information inside class structure
      weather.storePulse();
      // decrease number of pulses
      intArray[PLV_POS]--;
    }
    // Clear flag
    intFlag &= ~(PLV_INT); 
  }
  
  /////////////////////////////////////////////
  // 2.2. check RTC interruption
  /////////////////////////////////////////////
  if(intFlag & RTC_INT)
  {
    USB.println(F("+++ RTC interruption +++"));
    
    // switch on sensor board
    Agriculture.ON();
    
    RTC.ON();
    USB.print(F("Time:"));
    USB.println(RTC.getTime());    
        
    // measure sensors
    measureSensors();
    
    // Clear flag
    intFlag &= ~(RTC_INT); 
  }  
}
/*******************************************************************
 *
 *  measureSensors
 *
 *  This function reads from the sensors of the Weather Station and 
 *  then creates a new Waspmote Frame with the sensor fields in order 
 *  to prepare this information to be sent
 *
 *******************************************************************/
void measureSensors()
{  
  USB.println(F("------------- Measurement process ------------------"));
  
  /////////////////////////////////////////////////////
  // 1. Reading sensors
  ///////////////////////////////////////////////////// 
  // Read the anemometer sensor 
  anemometer = weather.readAnemometer();
  
  // Read the pluviometer sensor 
  pluviometer1 = weather.readPluviometerCurrent();
  pluviometer2 = weather.readPluviometerHour();
  pluviometer3 = weather.readPluviometerDay();
  
  /////////////////////////////////////////////////////
  // 2. USB: Print the weather values through the USB
  /////////////////////////////////////////////////////
  
  // Print the accumulated rainfall
  USB.print(F("1.1 Current hour accumulated rainfall (mm/h): "));
  USB.println( pluviometer1 );
  // Print the accumulated rainfall
  USB.print(F("1.2 Previous hour accumulated rainfall (mm/h): "));
  USB.println( pluviometer2 );
  // Print the accumulated rainfall
  USB.print(F("1.3 Last 24h accumulated rainfall (mm/day): "));
  USB.println( pluviometer3 );
  
  // Print the anemometer value
  USB.print(F("1.4 Anemometer: "));
  USB.print(anemometer);
  USB.println(F("km/h"));
    
  // Print the vane value
  char vane_str[10] = {0};
  switch(weather.readVaneDirection())
  {
  case  SENS_AGR_VANE_N   :  snprintf( vane_str, sizeof(vane_str), "N" );
                             break;
  case  SENS_AGR_VANE_NNE :  snprintf( vane_str, sizeof(vane_str), "NNE" );
                             break;  
  case  SENS_AGR_VANE_NE  :  snprintf( vane_str, sizeof(vane_str), "NE" );
                             break;    
  case  SENS_AGR_VANE_ENE :  snprintf( vane_str, sizeof(vane_str), "ENE" );
                             break;      
  case  SENS_AGR_VANE_E   :  snprintf( vane_str, sizeof(vane_str), "E" );
                             break;    
  case  SENS_AGR_VANE_ESE :  snprintf( vane_str, sizeof(vane_str), "ESE" );
                             break;  
  case  SENS_AGR_VANE_SE  :  snprintf( vane_str, sizeof(vane_str), "SE" );
                             break;    
  case  SENS_AGR_VANE_SSE :  snprintf( vane_str, sizeof(vane_str), "SSE" );
                             break;   
  case  SENS_AGR_VANE_S   :  snprintf( vane_str, sizeof(vane_str), "S" );
                             break; 
  case  SENS_AGR_VANE_SSW :  snprintf( vane_str, sizeof(vane_str), "SSW" );
                             break; 
  case  SENS_AGR_VANE_SW  :  snprintf( vane_str, sizeof(vane_str), "SW" );
                             break;  
  case  SENS_AGR_VANE_WSW :  snprintf( vane_str, sizeof(vane_str), "WSW" );
                             break; 
  case  SENS_AGR_VANE_W   :  snprintf( vane_str, sizeof(vane_str), "W" );
                             break;   
  case  SENS_AGR_VANE_WNW :  snprintf( vane_str, sizeof(vane_str), "WNW" );
                             break; 
  case  SENS_AGR_VANE_NW  :  snprintf( vane_str, sizeof(vane_str), "WN" );
                             break;
  case  SENS_AGR_VANE_NNW :  snprintf( vane_str, sizeof(vane_str), "NNW" );
                             break;  
  default                 :  snprintf( vane_str, sizeof(vane_str), "error" );
                             break;    
  }
  USB.println( vane_str );
  USB.println(F("----------------------------------------------------\n"));

  ///////////////////////////////////////////////// 2 //////////////////////////////////////////////
  // Part 1: Read the ultraviolet radiation sensor
  solarValue = radSensor.readRadiation();
  // Conversion from voltage into umol·m-2·s-1
  solarRadiation = solarValue / 0.0002;  
  
  // Part 2: USB printing
  // Print the radiation value through the USB
  USB.print(F("2. Solar Radiation: "));
  USB.print(solarRadiation);
  USB.println(F("umol*m-2*s-1"));

  //////////////////////////////////////////////// 3 //////////////////////////////////////////////
    // Part 1: Read the dendrometer sensor 
  denValue = dendSensor.readDendrometer();  
  
  // Part 2: USB printing
  // Print the Dendrometer value through the USB
  USB.print(F("3. Dendrometer: "));
  USB.printFloat(denValue,3);
  USB.println(F("mm"));
  
  
  //////////////////////////////  4 //////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////
  // 1. Read BME280: temp, hum, pressure
  /////////////////////////////////////// 
  
  temp = Agriculture.getTemperature();
  humd  = Agriculture.getHumidity();
  pres = Agriculture.getPressure();  
  ///////////////////////////////////////
  // 2. Print BME280 Values
  ///////////////////////////////////////
  USB.print(F("4.1 Temperature: "));
  USB.print(temp);
  USB.println(F(" Celsius"));
  USB.print(F("4.2 Humidity: "));
  USB.print(humd);
  USB.println(F(" %"));  
  USB.print(F("4.3 Pressure: "));
  USB.print(pres);
  USB.println(F(" Pa"));  
  USB.println(); 

  
  /////////////////////////////////////////////////// 5 ////////////////////////////////////////////////
  // Read the leaf wetness sensor 
  wetValue = lwSensor.getLeafWetness();  
  // show value
  USB.print("5. Leaf Wetness: ");
  USB.println(wetValue);

  /////////////////////////////////////////////////  6 ///////////////////////////////////////////
  // Part 1: Read Values
  // Read the ultrasound sensor 
  dist = Agriculture.getDistance();   
  
  // Part 2: USB printing
  // Print values through the USB
  USB.print(F("6. Distance: "));
  USB.print(dist);
  USB.println(F(" cm"));


  
 
  delay(1000);
}


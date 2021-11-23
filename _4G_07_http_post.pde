/*
    --------------- 4G_07 - HTTP POST  ---------------

    Explanation: This example shows how to send HTTP POST requests

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see .

    Version:           3.0
    Design:            David Gascón
    Implementation:    Alejandro Gállego
*/

#include <Wasp4G.h>

// APN settings
///////////////////////////////////////
char apn[] = "";
char login[] = "";
char password[] = "";
///////////////////////////////////////

// SERVER settings
///////////////////////////////////////
char host[] = "nckh.vn";
uint16_t port = 80;
char resource[] = "/RESTAPI.svc/json\n Content-Type: application/xml; charset=utf-8\n";
char data[] = "<UserData  xmlns=\"http://msdn.microsoft.com\"> <ID>10</ID></UserData>" ;
///////////////////////////////////////

// variables
int error;
float temp,humd,pres;


void setup()
{
  USB.ON();
  USB.println(F("Start program"));

  USB.println(F("********************************************************************"));
  USB.println(F("POST method to the Libelium's test url"));
  USB.println(F("You can use this php to test the HTTP connection of the module."));
  USB.println(F("The php returns the parameters that the user sends with the URL."));
  USB.println(F("********************************************************************"));


  //////////////////////////////////////////////////
  // 1. sets operator parameters
  //////////////////////////////////////////////////
  _4G.set_APN(apn, login, password);


  //////////////////////////////////////////////////
  // 2. Show APN settings via USB port
  //////////////////////////////////////////////////
  _4G.show_APN();
   // Turn on the sensor board
  Agriculture.ON();
}


void loop()
{
  temp = Agriculture.getTemperature();
  humd  = Agriculture.getHumidity();
  pres = Agriculture.getPressure();  
    ///////////////////////////////////////
  // 2. Print BME280 Values
  ///////////////////////////////////////
  USB.print(F("Temperature: "));
  USB.print(temp);
  USB.println(F(" Celsius"));
  USB.print(F("Humidity: "));
  USB.print(humd);
  USB.println(F(" %"));  
  USB.print(F("Pressure: "));
  USB.print(pres);
  USB.println(F(" Pa"));  
  USB.println(); 
  delay(1000);
  //////////////////////////////////////////////////
  // 1. Switch ON
  //////////////////////////////////////////////////
  error = _4G.ON();

  if (error == 0)
  {
    USB.println(F("1. 4G module ready..."));


    ////////////////////////////////////////////////
    // 2. HTTP POST
    ////////////////////////////////////////////////

    USB.print(F("2. HTTP POST request..."));

    // send the request
    error = _4G.http( Wasp4G::HTTP_POST, host, port, resource, data);

    // check the answer
    if (error == 0)
    {
      USB.print(F("Done. HTTP code: "));
      USB.println(_4G._httpCode);
      USB.print("Server response: ");
      USB.println(_4G._buffer, _4G._length);
    }
    else
    {
      USB.print(F("Failed. Error code: "));
      USB.println(error, DEC);
    }
  }
  else
  {
    // Problem with the communication with the 4G module
    USB.println(F("4G module not started"));
    USB.print(F("Error code: "));
    USB.println(error, DEC);
  }

  ////////////////////////////////////////////////
  // 3. Powers off the 4G module
  ////////////////////////////////////////////////
  USB.println(F("3. Switch OFF 4G module"));
  _4G.OFF();


  ////////////////////////////////////////////////
  // 4. Sleep
  ////////////////////////////////////////////////
  USB.println(F("4. Enter deep sleep..."));
  PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("5. Wake up!!\n\n"));
  

}

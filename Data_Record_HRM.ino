#include <driver/adc.h>

#define FALSE 0
#define TRUE 1
#define BINARY_TRANSFER TRUE

hw_timer_t * timer = NULL;

const int ledPin = 36;             // ledPin refers to ESP32 GPIO 2
//int xsensorPin = 12;
//int ysensorPin = 14;
//int zsensorPin = 27;

unsigned int x = 0;
//unsigned int y = 0;
//unsigned int z = 0;

void IRAM_ATTR onTimer() {

unsigned int x = adc1_get_raw(ADC1_CHANNEL_0);
// y = adc1_get_raw(ADC1_CHANNEL_3);
// z = adc1_get_raw(ADC1_CHANNEL_6);


  if (BINARY_TRANSFER)
  {
    Serial.write(x >> 8);
    Serial.write(x);

 //   Serial.write(y >> 8);
   // Serial.write(y);

    //Serial.write(z >> 8);
    //Serial.write(z);
  }
  else
  {
    Serial.print(x);
    Serial.print(" ");

  //  Serial.print(y);
  //  Serial.print(" ");

   // Serial.print(z);
   // Serial.println("");
  }
  /* x = analogRead(12);
    y = analogRead(14);
    z = analogRead(27);*/
}

void setup()
{
  Serial.begin(115200);           // initialize serial:
  pinMode(ledPin, OUTPUT);        // initialize digital pin ledPin as an output.
  for (int i = 0; i < 10; i++)
  {
    digitalWrite(ledPin, HIGH);
    delay(50);
    digitalWrite(ledPin, LOW);
    delay(50);
  }
  timer = timerBegin(0, 80, true);    // timer 0, MWDT clock period = 12.5 ns * TIMGn_Tx_WDT_CLK_PRESCALE -> 12.5 ns * 80 -> 1000 ns = 1 us, countUp
  timerAttachInterrupt(timer, &onTimer, true); // edge (not level) triggered
  timerAlarmWrite(timer, 1000, true); // 1000 * 1 us = 1 ms, autoreload true
  timerAlarmDisable(timer);           // disable timer

  adc1_config_width(ADC_WIDTH_BIT_12);
  adc1_config_channel_atten(ADC1_CHANNEL_0, ADC_ATTEN_DB_11);
  //adc1_config_channel_atten(ADC1_CHANNEL_3, ADC_ATTEN_DB_11);
  //adc1_config_channel_atten(ADC1_CHANNEL_6, ADC_ATTEN_DB_11);
}

void loop()
{
  serialEvent();
}

void serialEvent()
{
  while (Serial.available())
  {
    int inChar = Serial.read();       // get the new byte
    switch (inChar)
    {
      case 'S':
        digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
        timerAlarmEnable(timer);      // enable timer
        break;
      case 'E':
        digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
        timerAlarmDisable(timer);     // disable timer
        break;
      default:
        break;
    }
  }
}

#include <Wire.h>
#include <MPU6050.h>

int led=11;
MPU6050 mpu;

void setup() {
  // put your setup code here, to run once:
  
  mpu.begin(MPU6050_SCALE_2000DPS, MPU6050_RANGE_2G);
  
  mpu.setAccelPowerOnDelay(MPU6050_DELAY_3MS);

  mpu.setIntFreeFallEnabled(false);  
  mpu.setIntZeroMotionEnabled(false);
  mpu.setIntMotionEnabled(false);
  
  mpu.setDHPFMode(MPU6050_DHPF_5HZ);

  mpu.setMotionDetectionThreshold(4);
  mpu.setMotionDetectionDuration(5);

  mpu.setZeroMotionDetectionThreshold(4);
  mpu.setZeroMotionDetectionDuration(2);	
  
  pinMode(led,OUTPUT);
  Serial.begin(9600);
}

void loop() {
  Activites act = mpu.readActivites();
  int val1=analogRead(A0); //ldr
  int val2=analogRead(A1); //pressure
  
  Serial.print("a");
  Serial.print(val1);
  Serial.print("a");
  Serial.println();

  Serial.print("b");
  Serial.print(val2);
  Serial.print("b");
  Serial.println();

  Serial.print("c");
  if (act.isActivity)
  {
    Serial.print("1");    
  }
  else{
    Serial.print("0");
  }
  Serial.print("c");
  Serial.println();

  Serial.print("&");
  
  delay(100);
}
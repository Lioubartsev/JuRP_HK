/*
 * Version2 of "Controller with ROS" relies on 
 * AltSoftSerial which is much faster than SoftwareSerial
 * for HardwareSerial emulation. The downside is that
 * you consume 1 timer for this, and depending on how
 * ROS works there might not be enough timers for
 * the PWM signal for the driver. Version1 failed to
 * work with ROS probably because it was "too slow"
 * - it used up too much time in the loop() that 
 * "spinOnce()" isn't run often enough for ROS to
 * be synchronised, but with AltSoftSerial it seems to be working.
*/


#include <AltSoftSerial.h>

#include <ros.h>
#include <std_msgs/Empty.h>
#include <std_msgs/Int32.h>

#define PWMPIN 3 //The pin that will be going to the driver.

int32_t enc_count = 0;

AltSoftSerial encoderSerial;

ros::NodeHandle  nh; //To communicate with ROS
std_msgs::Int32 int_msg; //Type casting of the enc_count message


void messageCb( const std_msgs::Empty& toggle_msg){
  digitalWrite(13, HIGH-digitalRead(13));   // blink the led
}

ros::Subscriber<std_msgs::Empty> sub("toggle_led", &messageCb );
ros::Publisher arduino_printer("arduino_printer", &int_msg);

void setup() {
  //Set up the ROS
  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(arduino_printer);
  
  //Set up the AltSoftwareSerial
  encoderSerial.begin(9600);
  encoderSerial.flush();
  
  //make sure that the AltSoftwareSerial pins are input
  pinMode(8, INPUT);
  pinMode(9, INPUT);
  
  //Make pin the PWM output
  pinMode(PWMPIN, OUTPUT);

  
}

void loop() {
  enc_count = encoderSerial.parseInt();
  int_msg.data = enc_count;
  arduino_printer.publish(&int_msg);
  nh.spinOnce();

  
  
  analogWrite(PWMPIN, (abs(enc_count) % 256));
  

}

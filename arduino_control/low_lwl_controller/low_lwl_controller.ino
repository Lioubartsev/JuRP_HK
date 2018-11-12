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
#include <std_msgs/Int32.h>

#define PWMPIN 3 //The pin that will be going to the driver.

int32_t enc_count = 0;
int32_t current_pos = 0;
volatile int32_t reference_pos = 0;

AltSoftSerial encoderSerial;

ros::NodeHandle  nh; //To communicate with ROS
std_msgs::Int32 int_msg; //Type casting of the enc_count message


void updatereference_pos( const std_msgs::Int32& new_reference_pos_msg){
  reference_pos = new_reference_pos_msg.data;
}

ros::Subscriber<std_msgs::Int32> sub("low_lwl_reference", &updatereference_pos);
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
  //int_msg.data = enc_count;
  //arduino_printer.publish(&int_msg);
  //nh.spinOnce();
  
  current_pos = enc_count;//(abs(enc_count) % 256)
  
  //analogWrite(PWMPIN, P_controller(reference_pos, current_pos));
  int_msg.data = P_controller(reference_pos, current_pos);
  arduino_printer.publish(&int_msg);
  nh.spinOnce();
}

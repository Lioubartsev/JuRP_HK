

#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
#endif

#include <Servo.h> 
#include <ros.h>
#include <std_msgs/UInt16.h>
#include <std_msgs/String.h>


std_msgs::String str_msg;
std_msgs::UInt16 int_msg;
std_msgs::UInt16 Uint_msg;
ros::NodeHandle  nh;




ros::Publisher chatter("position", &Uint_msg); // DEBUG test int output
void Zref_cb( const std_msgs::UInt16& cmd_msg);
ros::Subscriber<std_msgs::UInt16> sub("Zref", Zref_cb);

//========================================================//
volatile long enc_count = 0;
static uint8_t enc_val = 0;
static int8_t lookup_table[] = {0, -1, 1, 0, 1, 0, 0, -1, -1, 0, 0, 1, 0, 1, -1, 0};
// ttps://makeatronics.blogspot.tw/2013/02/efficiently-reading-quadrature-with.html 
//the point is to figure out which direction the motor is rotating.
//By using the new and old A and B values you can look it up in a table.
//That table will tell if you have gone one step forward (1), backward (-1) or if the motor has stood


int goal_enc_count = 13000; //the initial value of the "goal encoder value (encoder value
int rough_place = 1; //used to make it easier to send position commands from the arduino
float err = 0;
float inp = 0;
float P = 0.05;
float I = 0;
float D = 0;
int pwmPin = 10; //5;
int dirPin = 11;
float duty = 0; //initialize duty cycle

float temp =0;

void setup() {

  nh.initNode(); //ros init stuff
  nh.subscribe(sub);
  nh.advertise(chatter); //DEBUG

  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  //pinMode(5, OUTPUT); //OCR0B, aka PWMpin

  pinMode(13, OUTPUT);


   
  attachInterrupt(digitalPinToInterrupt(2), encoder_isr, CHANGE);
  attachInterrupt(digitalPinToInterrupt(3), encoder_isr, CHANGE); //attach pins 2 and 3 to the interrupt

  //OCR0B, aka PWMpin is 5
  digitalWrite(pwmPin, OUTPUT); //make these two ouput pins
  digitalWrite(dirPin, OUTPUT);

  initPWM();

}

void loop() {

  nh.spinOnce();
  //digitalWrite(13, HIGH);
  //setPWM(0);

  
  //We have an incredicly crude p-controller that either moves the end effector up or down depending on where it is in relation
  //to the encoder position, as well as try to put the whole machine in a "maintaining vertical position"-mode when it is within a span.
  /*
  if (enc_count <= goal_enc_count - 750) {
    Upp();
  }
  else if (enc_count >= goal_enc_count + 750) {
    Ned();
  }
  else {
    Maintain();
  }
  */
}

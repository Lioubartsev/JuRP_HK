#include <SoftwareSerial.h>
#include <ros.h>
#include <std_msgs/Empty.h>
//#include <std_msgs/String.h>
#include <std_msgs/Int32.h>

#define RX_pin 9  //RX is digital pin 9(connect to TX of other device)
#define TX_pin 11  //TX is digital pin 11 (connect to RX of other device)

int32_t enc_count = 0;
int posDelta = 0;
volatile int32_t compactMsg = 0;
int msg = 0;
int msgCheck = 0;

SoftwareSerial encoderSerial(RX_pin, TX_pin);

ros::NodeHandle  nh;

//std_msgs::String str_msg;
std_msgs::Int32 int_msg;
char hello[13] = "hello world!";

void messageCb( const std_msgs::Empty& toggle_msg){
  digitalWrite(13, HIGH-digitalRead(13));   // blink the led
}

ros::Subscriber<std_msgs::Empty> sub("toggle_led", &messageCb );
ros::Publisher arduino_printer("arduino_printer", &int_msg);

void setup() {
  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(arduino_printer);
  /*
  //Set up the hardware serial for debugging
  Serial.begin(9600); //for manual debugging, with no ROS
  Serial.flush();*/
  
  //Set up the software serial
  //encoderSerial.begin(9600);
  //encoderSerial.flush();
  
  //make sure that the software serial pins are input
  pinMode(RX_pin, INPUT);
  pinMode(TX_pin, INPUT);
  
  //Make pin 7 an input
  pinMode(7, INPUT);


  pinMode(13, OUTPUT);
  
}

void loop() {
  
  // The bit-shifting method
  compactMsg = encoderSerial.parseInt();
  enc_count = compactMsg>>10;
  
  enc_count = compactMsg;
  //encoderSerial.flush();
  
  int_msg.data = enc_count;
  arduino_printer.publish(&int_msg);
  nh.spinOnce();
  delay(10);

}

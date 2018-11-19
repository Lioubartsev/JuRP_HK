#include <AltSoftSerial.h>

#include <ros.h>
#include <std_msgs/Int32.h>

#define PWM_VALUE_PIN 3 // Value of PWM to driver
#define PWM_DIR_PIN 5 // Direction of PWM to driver
#define PWM_POSITIVE_DIR HIGH
#define PWM_NEGATIVE_DIR LOW

int32_t enc_count = 0;
int32_t current_pos = 0;
int32_t u = 0;
int32_t new_pwm = 0;
volatile int32_t reference_pos = 0;

AltSoftSerial encoderSerial;

ros::NodeHandle  nh; //To communicate with ROS
std_msgs::Int32 int_msg; //Type casting of the enc_count message


void updatereference_pos( const std_msgs::Int32& new_reference_deg_msg){
  reference_pos = 2305/360 * new_reference_deg_msg.data; // 2305 counts/rev with input in degrees
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
  pinMode(PWM_VALUE_PIN, OUTPUT);
}

void loop() {
  enc_count = encoderSerial.parseInt();
  //int_msg.data = enc_count;
  //arduino_printer.publish(&int_msg);
  //nh.spinOnce();
  
  current_pos = enc_count;
  
  u = P_controller(reference_pos, current_pos);
  new_pwm = u_to_pwm(u);

  // Set direction of rotation to driver
  if(new_pwm >= 0) {
    digitalWrite(PWM_DIR_PIN, PWM_POSITIVE_DIR);
  } else {
    digitalWrite(PWM_DIR_PIN, PWM_NEGATIVE_DIR);
  }

  // Set value of PWM to driver
  analogWrite(PWM_VALUE_PIN, abs(new_pwm));

  int_msg.data = u;
  arduino_printer.publish(&int_msg);
  nh.spinOnce();
}

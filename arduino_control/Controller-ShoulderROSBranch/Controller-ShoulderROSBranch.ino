#define PWM_VALUE_PIN 3 // Value of PWM to driver
#define PWM_DIR_PIN 4 // Direction of PWM to driver
#define PWM_POSITIVE_DIR LOW
#define PWM_NEGATIVE_DIR HIGH
#include <AltSoftSerial.h>
#include <ros.h>
#include <std_msgs/Int16.h>
AltSoftSerial breakfastSerial;

void messageCb( const std_msgs::Int16& reference);
int32_t e_to_pwm(float e, float e_old, double e_sum);
void do_PID_stuff(float current_pos, float reference_pos);
float get_serial_value();

float motor_ref = 0; // reference from ros
float motor_pos = 0; //motor position from nano

float gear_ratio = 45;

ros::NodeHandle  nh; //ROS
std_msgs::Int16 int_msg_4;
ros::Publisher chatter_3("chatter_3", &int_msg_4);
ros::Subscriber<std_msgs::Int16> sub("shoulder_reference", &messageCb);

int32_t enc_count = 0;
int32_t current_pos = 0;
float e = 0; //error
float e_old = 0; //previous sample error, necessary for d-calculation
double e_sum = 0; //sum of all errors so far, necessary for i-calculation
int32_t new_pwm = 0;

static long int time_new = 0; //timer [DELETE THIS LATER]

int start_program_bool = 0;
int temp_char = 0;

int posDelta = 0;
volatile int32_t  compactMsg = 0;
int msg = 0;
int msgCheck = 0;

int counter = 0;

void setup() {
  //Set up ROS
  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(chatter_3);

  //Set up the software serial
  breakfastSerial.begin(74880);
  breakfastSerial.flush();
  //make sure that the software serial pins are input
  pinMode(8, INPUT);
  pinMode(9, INPUT);

  //Make pin 7 an input
  //pinMode(7, INPUT);

  pinMode(PWM_VALUE_PIN, OUTPUT); //PWM PIN!
  pinMode(PWM_DIR_PIN, OUTPUT); //DIR PIN!
  ////////////////////////////////////////////// DEBUG TIMER /////////////////////////////////////////////

  //delay(10000);
  //  int16_t debug1 = micros();
  //  delay(10);
  //  int_msg_4.data = debug1 - micros();
  //int_msg_4.data = 0;
  //chatter_3.publish( &int_msg_4 );

  ///////////////////////////////////////////////////////////////////////////////////////////////////////
}

void loop() {
  motor_pos = get_serial_value();         //read encoder
  nh.spinOnce();                          //read ref

  if ( motor_pos < 10 )
  {

    if ( motor_ref - motor_pos  <  0  )
    {
      do_PID_stuff( 2 , 0.01 , 0); //(p: 3-4 is good)
    }
    else
    {
      do_PID_stuff( 5 , 0.01 , 20000); //(p: 3-4 is good)
    }



  }
  else if ( motor_pos < 20 )
  {


    if ( motor_ref - motor_pos  <  0 )
    {
      do_PID_stuff( 5 , 0.01 , 0); //(p: 3-4 is good)
    }
    else
    {
      do_PID_stuff( 8 , 0.01 , 60000 );
    }



  }
  else if ( motor_pos < 30 )
  {


    if ( motor_ref - motor_pos  <  0 )
    {
      do_PID_stuff( 5 , 0.01 , 60000); //(p: 3-4 is good)
    }
    else
    {
      do_PID_stuff( 12, 0.01 , 140000 );
    }


  }
  else
  {


    if ( motor_ref - motor_pos  <  0 )
    {
      do_PID_stuff( 5 , 0.01 , 10000); //(p: 3-4 is good)
    }
    else
    {
      do_PID_stuff( 13, 0.01 , 100000);
    }

    
  }

  counter++;

}

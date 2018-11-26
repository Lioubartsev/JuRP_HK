#include <ros.h>
//#include <std_msgs/Float32.h>
//#include <std_msgs/Float32MultiArray.h>
//#include <std_msgs/Int32MultiArray.h>
//#include <std_msgs/Int8MultiArray.h>
//#include <std_msgs/Int8.h>
//#include <std_msgs/String.h>
//#include <std_msgs/Int32.h>
#include <std_msgs/Int16.h>

float motor_ref[40];
int16_t Dennis_ptr = 0;
ros::NodeHandle  nh;

//std_msgs::Int32 int_msg_1;
//std_msgs::Int32MultiArray int_msg;
//std_msgs::Int8MultiArray int_msg_2;
//std_msgs::Int8 int_msg_3;
std_msgs::Int16 int_msg_4;

//std_msgs::Float32 float_msg_1;
//std_msgs::Float32MultiArray float_msg;

ros::Publisher chatter_3("chatter_3", &int_msg_4);

void messageCb( const std_msgs::Int16& reference)
{
    //motor_ref[Dennis_ptr] = reference.data;
    int_msg_4.data = reference.data;
    chatter_3.publish( &int_msg_4 );
    //Dennis_ptr ++ ;
}

ros::Subscriber<std_msgs::Int16> sub("shoulder_reference", &messageCb);

void setup()
{

  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(chatter_3);
}

void loop()
{
  delay(1);
  nh.spinOnce();
}

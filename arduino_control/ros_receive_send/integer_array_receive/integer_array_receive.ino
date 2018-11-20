
#include <ros.h>
#include <std_msgs/Float32.h>
#include <std_msgs/Float32MultiArray.h>
#include <std_msgs/Int32.h>
#include <std_msgs/Int32MultiArray.h>
#include <std_msgs/String.h>

ros::NodeHandle  nh;

std_msgs::Int32 int_msg_1;
std_msgs::Int32MultiArray int_msg;

std_msgs::Float32 float_msg_1;
std_msgs::Float32MultiArray float_msg;

std_msgs::String str_msg;

ros::Publisher chatter_3("chatter_3", &int_msg_1);
//char hello[20] = "123456789123456789!";


void messageCb( const std_msgs::Int32MultiArray& reference_array){

  //int_msg_1.data = reference_array.data[5]; //reference_array.data;
  //float_msg.data = 55;
  
  int_msg_1.data = reference_array.data[5];
  chatter_3.publish( &int_msg_1 );

  /*
  char hello[20] = "VALUEEEEEEEEEEEEEEE";
  str_msg.data = hello;
  chatter_3.publish( &str_msg );
  digitalWrite(13, HIGH-digitalRead(13));
  */
}

ros::Subscriber<std_msgs::Int32MultiArray> sub("shoulder_reference", &messageCb);

void setup()
{

  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(chatter_3);
  //str_msg.data = hello;
  int_msg_1.data = 1000;
}

void loop()
{
  //str_msg.data = hello;
  //chatter_3.publish( &str_msg );
  nh.spinOnce();
  delay(100);
}

#include <ros.h>
#include <std_msgs/Float32.h>
#include <std_msgs/Float32MultiArray.h>
#include <std_msgs/Int32.h>
#include <std_msgs/Int32MultiArray.h>
#include <std_msgs/Int8MultiArray.h>
#include <std_msgs/Int8.h>
#include <std_msgs/String.h>

int8_t motor_ref[40];
int8_t endn = 0;
int8_t j = 0;
ros::NodeHandle  nh;

std_msgs::Int32 int_msg_1;
std_msgs::Int32MultiArray int_msg;
std_msgs::Int8MultiArray int_msg_2;
std_msgs::Int8 int_msg_3;

std_msgs::Float32 float_msg_1;
std_msgs::Float32MultiArray float_msg;

std_msgs::String str_msg;

ros::Publisher chatter_3("chatter_3", &int_msg_3);
//char hello[20] = "123456789123456789!";


void messageCb( const std_msgs::Int8MultiArray& reference_array)
{
  
  for( int i = 0; i<10; i++)
  {
    j = i + endn;
    motor_ref[j] = reference_array.data[i];
  }
  endn+=10;

}

ros::Subscriber<std_msgs::Int8MultiArray> sub("shoulder_reference", &messageCb);

void setup()
{

  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(chatter_3);
}

void loop()
{
  nh.spinOnce();

  if(endn >= 50)
  {
    endn = 0;
    for(int i = 0; i < 40; i++)
    {
      int_msg_3.data = motor_ref[i];
      chatter_3.publish( &int_msg_3 );
    }
  }
  
  delay(1);
}

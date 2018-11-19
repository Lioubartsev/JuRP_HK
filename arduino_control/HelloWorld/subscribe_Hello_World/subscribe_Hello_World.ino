#include <ros.h>
#include <std_msgs/String.h>
#include <std_msgs/Empty.h>
ros::NodeHandle  nh;

void messageCb( const std_msgs::Empty& toggle_msg){
     
  }
  
std_msgs::String str_msg;

ros::Subscriber<std_msgs::Empty> sub("chatter", &messageCb);
ros::Publisher chatter_2("chatter_2", &str_msg);

char hello[13] = "hello world!";

void setup()
{
  nh.initNode();
  nh.advertise(chatter_2);
}

void loop()
{
  str_msg.data = hello;
  chatter_2.publish( &str_msg );
  nh.spinOnce();
  delay(1000);
}

%rosshutdown
%rosinit
angle = -600;

%while(1)



upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
upper_reference_msg = rosmessage(upper_reference);


%shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int32MultiArray');
%shoulder_reference_msg = rosmessage(shoulder_reference);

%shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int32');
%shoulder_reference_msg = rosmessage(shoulder_reference);

upper_reference_msg.Data = angle;

send(upper_reference, upper_reference_msg) 

%pause(1)
%end
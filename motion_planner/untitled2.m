rosshutdown
rosinit
%while(1)
values = [1 2 3 4 5 6 7 8 9];
values = rand(10,1);

shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Float32MultiArray');
shoulder_reference_msg = rosmessage(shoulder_reference);


%shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int32MultiArray');
%shoulder_reference_msg = rosmessage(shoulder_reference);

%shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int32');
%shoulder_reference_msg = rosmessage(shoulder_reference);

shoulder_reference_msg.Data = values;
send(shoulder_reference, shoulder_reference_msg) 

%end
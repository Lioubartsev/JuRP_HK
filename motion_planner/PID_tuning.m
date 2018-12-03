rosshutdown
rosinit
angle = 0;
angle = angle*10;

shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
shoulder_reference_msg = rosmessage(shoulder_reference);

%upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
%upper_reference_msg = rosmessage(upper_reference);

% elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
% elbow_reference_msg = rosmessage(elbow_reference);

shoulder_reference_msg.Data = angle;
send(shoulder_reference, shoulder_reference_msg) 


%upper_reference_msg.Data = angle;
%send(upper_reference, upper_reference_msg) 

% elbow_reference_msg.Data = angle;
% send(elbow_reference, elbow_reference_msg);

%pause(1)
%end
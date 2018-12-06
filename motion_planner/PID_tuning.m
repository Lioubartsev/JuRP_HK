%% Iitializations
rosshutdown
rosinit

angle = 660;
angle = angle*10;

shoulder = 0;
upper = 0;
elbow = 1;

%% Set the publishers
if(shoulder)
shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
shoulder_reference_msg = rosmessage(shoulder_reference);
end

if(upper)
upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
upper_reference_msg = rosmessage(upper_reference);
end

if(elbow)
 elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
 elbow_reference_msg = rosmessage(elbow_reference);
end
%% Send the reference

if(shoulder)
shoulder_reference_msg.Data = angle;
send(shoulder_reference, shoulder_reference_msg) 
end

if(upper)
upper_reference_msg.Data = angle;
send(upper_reference, upper_reference_msg) 
end

if(elbow)
elbow_reference_msg.Data = angle;
send(elbow_reference, elbow_reference_msg);
end
pause(1)
%end
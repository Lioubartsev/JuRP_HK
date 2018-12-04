%Simulate sending some values to the LQR instead of throwing the ball
%physically
%% Initilization of ROS
rosshutdown
rosinit

context.DEV_MODE = 1; 

context.Sim_mode = 1;


%subscribe to get current position
shoulder_pos_ros = rossubscriber('/shoulder_pos');
% upper_pos_ros = rossubscriber('/upper_pos');
% elbow_pos_ros = rossubscriber('/elbow_pos');

%Publish positions to arduino
shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
shoulder_reference_msg = rosmessage(shoulder_reference);
% upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
% upper_reference_msg = rosmessage(upper_reference);
% elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
% elbow_reference_msg = rosmessage(elbow_reference);

%Origin relation between vicon and LQR
Origin_shift = [1.098 0.850 0.412]'

%% Send initial values

shoulder_data = receive(shoulder_pos_ros, 10);
shoulder_pos = shoulder_data.Data;
shoulder_pos_val = (cast(shoulder_pos, 'double')-900) *2*pi/(10*360);


% upper_data = receive(upper_pos_ros, 10);
% upper_pos = upper_data.Data;
% upper_pos_val = (cast(upper_pos, 'double')-0) *2*pi/(10*360);

% elbow_data = receive(elbow_pos_ros, 10);
% elbow_pos = elbow_data.Data;
% elbow_pos_val = (cast(elbow_pos, 'double')) *2*pi/(10*360);

%% Send the initial references for testing
    
shoulder_reference_msg.Data = shoulder_pos_val;
send(shoulder_reference, shoulder_reference_msg);

% elbow_reference_msg.Data = elbow_pos_val;
% send(elbow_reference, elbow_reference_msg);
% 
% upper_reference_msg.Data = upper_pos_val;
% send(upper_reference, upper_reference_msg);
    

%% Send parameters to the LQR
q = [shoulder_pos_val upper_pos_val elbow_pos_val ]' %elbow_pos_val]';

x_prediction = 180 / 1000 ;
y_prediction = 1375 / 1000;
z_prediction = 350 / 1000 ;

state_trgt = [y_prediction x_prediction z_prediction]' - Origin_shift;
state_trgt = diag([1 -1 1])*state_trgt;

[q_traj] = InvKinLQR(q, state_trgt, context);

q_traj = q_traj * 10 * 360 / (2 * pi) ;
q_traj(1,:) = q_traj(1,:) + 900;


for i= 1:length(q_traj)
    shoulder_reference_msg.Data = q_traj(1, i);
    send(shoulder_reference, shoulder_reference_msg);
%     elbow_reference_msg.Data = q_traj(2, i);
%     send(elbow_reference, elbow_reference_msg);
%     upper_reference_msg.Data = q_traj(3, i);
%     send(upper_reference, upper_reference_msg);
    pause(0.05); 
end
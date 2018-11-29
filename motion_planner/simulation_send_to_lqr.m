%Simulate sending some values to the LQR instead of throwing the ball
%physically
%% Initilization of ROS
rosshutdown
rosinit

%subscribe to get current position
shoulder_pos_ros = rossubscriber('/shoulder_pos');
upper_pos_ros = rossubscriber('/upper_pos');
elbow_pos_ros = rossubscriber('/elbow_pos');

%Publish positions to arduino
shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
shoulder_reference_msg = rosmessage(shoulder_reference);
upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
upper_reference_msg = rosmessage(upper_reference);
elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
elbow_reference_msg = rosmessage(elobw_reference);

%Origin relation between vicon and LQR
Origin_shift = [1.098 0.850 0.412]'

%% Send initial values
shoulder_data = receive(shoulder_pos_ros, 10);
shoulder_pos = shoulder_data.Data;
shoulder_pos_val = (cast(shoulder_pos, 'double')-900) *2*pi/(10*360);

upper_data = receive(upper_pos_ros, 10);
upper_pos = upper_data.Data;
upper_pos_val = (cast(upper_pos, 'double')-0) *2*pi/(10*360);

elbow_data = receive(elbow_pos_ros, 10);
elbow_pos = elbow_data.Data;
elbow_pos_val = (cast(elbow_pos, 'double')+900) *2*pi/(10*360);

%% Send parameters to the LQR
q = [shoulder_pos_val upper_pos_val elbow_pos_val]';

x_prediction =
y_prediction = 
z_prediction =

state_trgt = [y_prediction x_prediction z_prediction]' - Origin_shift;
state_trgt = diag([1 -1 1])*state_trgt;

[q_traj] = InvKinLQR(q, state_trgt, context);
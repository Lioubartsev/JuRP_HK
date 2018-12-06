%% motion_planner

close all
clear all
%clc

% Run test with local sample?
context.DEV_ENVIRONMENT = 0;

% (if running with local sample) Which?
context.DEV_SAMPLE = 3;

% At which height is the ball considered "in the air"? [mm]
context.z_threshold = 90 / 1000;

% At which height will end effector catch the ball? [mm]
context.z_intercept = -40/1000;

%Which method to use for calculating the projection )
% Method 1: Wait till we reach the maximum point then calculate.
% Method 2: Calculate the projection using a timer and velocities. based on
%           n points
context.method = 2;

% Sampling frequency
context.fs = 100;

% Number of samples for Method 2
context.length_sample = 15;

%Automatic throw ?
context.Automatic = 1;

% Verbose mode? plot and and more..
context.DEV_MODE = 0; 

% Set up environment
addpath(genpath(pwd));
if context.DEV_ENVIRONMENT
    disp("RUNNING IN LOCAL ENVIRONMENT")
    disp("............")
else
    disp("RUNNING IN ROS ENVIRONMENT")
    disp("............")
   rosshutdown
   rosinit
    
    context.ou = rossubscriber('/object_update');
    %shoulder_pos_ros = rossubscriber('/shoulder_pos');
    upper_pos_ros = rossubscriber('/upper_pos');
    elbow_pos_ros = rossubscriber('/elbow_pos');
    
end
    
%shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
%shoulder_reference_msg = rosmessage(shoulder_reference);

 upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
 upper_reference_msg = rosmessage(upper_reference);

elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
elbow_reference_msg = rosmessage(elbow_reference);

if(context.Automatic)
    input('Press any key to throw the ball');
    
    angle = -660;
    elbow_reference_msg.Data = angle * 10;
    send(elbow_reference, elbow_reference_msg);
    
%    shoulder_reference_msg.Data = angle * 10;
%    send(shoulder_reference, shoulder_reference_msg); 

end

%% Track & predict landing
tic


[x_prediction, y_prediction] = ball_trajectory_calculater(context);
%fprintf('Predicted landing [x, y] = [%g, %g] mm\n', x_prediction, y_prediction);
%% Calculate arm trajectory
toc
%shoulder_data = receive(shoulder_pos_ros, 10);
%shoulder_pos = shoulder_data.Data;
%shoulder_pos_val = (cast(shoulder_pos, 'double')-900) *2*pi/(10*360); % Radians   
shoulder_pos_val = (cast( 0, 'double')-900) *2*pi/(10*360); % Radians 

%upper_data = receive(upper_pos_ros, 10);
%upper_pos = upper_data.Data;
%upper_pos_val = (cast(upper_pos, 'double')-0) *2*pi/(10*360);
upper_pos_val = (cast(0, 'double')-0) *2*pi/(10*360);;

%elbow_data = receive(elbow_pos_ros, 10);
%elbow_pos = elbow_data.Data;   %Degrees * 10
%elbow_pos_val = (cast(elbow_pos, 'double')) *2*pi/(10*360); % Radians
elbow_pos_val = (cast(550, 'double')) *2*pi/(10*360); % Radians

toc
q = [shoulder_pos_val upper_pos_val elbow_pos_val]';

%Coordinate transformation from Vicon to LQR
[x, y, z] = Transform_coordinates(x_prediction, y_prediction, context.z_intercept);
state_trgt = [x y z]';

[q_traj] = InvKinLQR(q, state_trgt, context);

toc
%% Send control signal

%Compress data
q_traj = q_traj * 10 * 360 / (2 * pi) ; % Angle * 10

q_traj(1,:) = q_traj(1,:) + 900; %Angle in terms of the local encoder's angle system

for i= 1:length(q_traj)-1
    %shoulder_reference_msg.Data = q_traj(1, i);
    %send(shoulder_reference, shoulder_reference_msg);
    
    upper_reference_msg.Data = q_traj(2, i);
    send(upper_reference, upper_reference_msg);
    
    elbow_reference_msg.Data = q_traj(3, i);
    send(elbow_reference, elbow_reference_msg);
    
    pause(0.001);
end

toc

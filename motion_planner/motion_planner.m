%% motion_planner

close all
clear all
%clc

% Run test with local sample?
context.DEV_ENVIRONMENT = 1;

% (if running with local sample) Which?
context.DEV_SAMPLE = 3;

% At which height is the ball considered "in the air"? [mm]
context.z_threshold = 0.6;

% At which height will end effector catch the ball? [mm]
context.z_intercept = 0.6;

%Which method to use for calculating the projection )
% Method 1: Wait till we reach the maximum point then calculate.
% Method 2: Calculate the projection using a timer and velocities. based on
%           n points
context.method = 2;

% Sampling frequency
context.fs = 100;

% Number of samples for Method 2
context.length_sample = 20;

% Verbose mode? plot and and more..
context.DEV_MODE = 1; 

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
    %context.ou.LatestMessage
    %at = rospublisher('/arm_trajectory','std_msgs/String');
    %arm_trajectory_msg = rosmessage(at);
    
%     shoulder_reference = rospublisher("/shoulder_reference", 'std_msgs/Int32MultiArray');
%     shoulder_reference_msg = rosmessage(shoulder_reference);
end
    
shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int32MultiArray');
shoulder_reference_msg = rosmessage(shoulder_reference);

%% Throw

% Performed manually

%% Track & predict landing
tic
[x_prediction, y_prediction] = ball_trajectory_calculater(context);
%fprintf('Predicted landing [x, y] = [%g, %g] mm\n', x_prediction, y_prediction);
%% Calculate arm trajectory
q = [-0.1 0 0]';
state_trgt = [0 0.5 0]';

[q_traj] = InvKinLQR(q, state_trgt, context);
toc
%% Send control signal

% if DEV_ENVIRONMENT
%     % Do nothing
% else
%    shoulder_reference_msg.Data = q_traj(3, :);
%    send(shoulder_reference, shoulder_reference_msg) 
% end

shoulder_reference_msg.Data = q_traj(3, :);
send(shoulder_reference, shoulder_reference_msg) 
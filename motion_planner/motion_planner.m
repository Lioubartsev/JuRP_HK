%% motion_planner

close all
clear all
clc

% Run test with local sample?
context.DEV_ENVIRONMENT = 1;

% (if running with local sample) Which?
context.DEV_SAMPLE = 3;

% At which height is the ball considered "in the air"? [mm]
context.z_threshold = 600;

% At which height will end effector catch the ball? [mm]
context.z_intercept = 600;

%Which method to use for calculating the projection )
%Method 1: Wait till we reach the maximum point then calculate.
%Method 2: Calculate the projection using a timer and velocities.
context.Method = 2;


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
    %at = rospublisher('/arm_trajectory','std_msgs/String');
    %arm_trajectory_msg = rosmessage(at);
end
    
%% Throw

% Performed manually

%% Track & predict landing

[x_prediction, y_prediction, vx, vy, vz, t_stamp] = ball_trajectory_calculater(context);
fprintf('Predicted landing [x, y] = [%g, %g] mm\n', x_prediction, y_prediction);
%% Calculate arm trajectory
q = [-0.1 0 0]';
state_trgt = [0 0.5 0]';

[q_traj] = InvKinLQR(q, state_trgt);

%% Send control signal

% if DEV_ENVIRONMENT
%     % Do nothing
% else
%    arm_reference_msg.Data = strcat(num2str(x_intersect), ';', num2str(y_intersect));
%    send(at, arm_trajectory_msg) 
% end
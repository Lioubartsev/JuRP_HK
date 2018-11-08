%% motion_planner

close all
clear all
clc

% Run test with local sample?
context.DEV_ENVIRONMENT = 0;

% (if running with local sample) Which?
context.DEV_SAMPLE = 2;

% At which height is the ball considered "in the air"? [mm]
context.z_threshold = 600;

% At which height will end effector catch the ball? [mm]
context.z_intercept = 600;

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

[x_prediction, y_prediction] = ball_trajectory_calculater(context);

%% Calculate arm trajectory

%% Send control signal

fprintf('Predicted landing [x, y] = [%g, %g] mm\n', x_prediction, y_prediction);
% if DEV_ENVIRONMENT
%     % Do nothing
% else
%    arm_reference_msg.Data = strcat(num2str(x_intersect), ';', num2str(y_intersect));
%    send(at, arm_trajectory_msg) 
% end
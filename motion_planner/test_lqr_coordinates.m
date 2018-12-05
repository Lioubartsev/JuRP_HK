
%% Vicon global coordinate of ball %slight above origin
% x_prediction = -774 / 1000; %m
% y_prediction = 1072 / 1000; %m
% z_prediction  = 426 / 1000; %m %370

%elbow
% x_prediction = 746 / 1000; %m
% y_prediction = 306 / 1000; %m
% z_prediction  = 378 / 1000; %m

%EE
x_prediction = 826 / 1000; %m
y_prediction = 760 / 1000; %m
z_prediction  = 398 / 1000; %m

%% Transformation and output
[x_prediction y_prediction z_prediction] = Transform_coordinates(x_prediction, y_prediction, z_prediction)
state_trgt = [x_prediction y_prediction z_prediction];
state_trgt = state_trgt*100
LQR_shoulder = [6 89.5 7]


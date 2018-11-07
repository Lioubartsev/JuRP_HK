close all
clear all
clc

%% Select the Ennvironment type
DEV_ENVIRONMENT = 1;
DEV_SAMPLE = 1;

if DEV_ENVIRONMENT
    disp("RUNNING IN LOCAL ENVIRONMENT")
    disp("............")
    load(strcat('samples/sample', int2str(DEV_SAMPLE), '.mat'))
    sample_x = x_points;
    sample_y = y_points;
    sample_z = z_points;
else
    disp("RUNNING IN ROS ENVIRONMENT")
    disp("............")
    rosshutdown
    rosinit
    rostopic list

    rostopic info /object_update

    ou = rossubscriber('/object_update')
end

x_points = [];
y_points = [];
z_points = [];

%% Visualize throw
% figure
% 
% plot(sample_x(1), sample_z(1))
% hold on
% for i = 2:numel(sample_z)
%     plot(sample_x(i), sample_z(i), '+')
%     hold on
%     pause(0.05)
%     sample_z(i)
% end

%% Collect data points

%Check to see if ball has been thrown in the air

z_threshold = 600;      %Threshold for the ball to be considered in the air
z_intercept = 600;      %Z-plane for the end effector to catch the ball

if DEV_ENVIRONMENT
    i = 1;
    while points(i).Objects.Z < z_threshold
        i = i + 1;
    end
    data_array = i:i+50;
else
    data = receive(ou, 10);
    while(data.Objects.Z < z_threshold)
        data = receive(ou, 10);
    end
    data_array = 1:50;
end

for i = data_array
    if DEV_ENVIRONMENT
        data = points(i);
    else
        data = receive(ou, 10);
    end

    if length(z_points)>1 && (data.Objects.Z - z_points(end)) < 0
        xz_max = x_points(end);
        yz_max = y_points(end);
        
        break
    else
        x_points = [x_points data.Objects.X];
        y_points = [y_points data.Objects.Y];
        z_points = [z_points data.Objects.Z];
    end
    
end

% Store a copy of the actual data points before manipulation
actual_x = x_points;
actual_y = y_points;
actual_z = z_points;

stop_ptr = numel(actual_x);


%% Fit curve trajectory

%Step 1: Reflect points about the maximum z-point
[reflection_x, reflection_y, reflection_z] = Mirror(x_points, y_points, z_points, xz_max, yz_max);

x_points = [x_points reflection_x];
y_points = [y_points reflection_y];
z_points = [z_points reflection_z];

%Step 2: Determine the direction of the juggling in the x-axis and y-axis
if x_points(1) < x_points(end)
    is_positive_direction_x = 1;
else
    is_positive_direction_x = 0;
end

if y_points(1) < y_points(end)
    is_positive_direction_y = 1;
else
    is_positive_direction_y = 0;
end

%Step 3: Fit a curve through the reflected points
fit_xz_reflection = polyfit(reflection_x', reflection_z', 2);
fit_yz_reflection = polyfit(reflection_y', reflection_z', 2);


%% Calculate the interception points
[x_intersect, y_intersect] = get_intersection(fit_xz_reflection, fit_yz_reflection, z_intercept);

if is_positive_direction_x
    x_intersect = max(x_intersect);
else
    x_intersect = min(x_intersect);
end

if is_positive_direction_y
    y_intersect = max(y_intersect);
else
    y_intersect = min(y_intersect);
end
disp("Predicted X-intercept: ");
x_intersect
disp("Predicted Y-intercept: ");
y_intersect

%% Continue sampling the actual data points


% if DEV_ENVIRONMENT
% else   
%     data = receive(ou, 10);
%     while(data.Objects.Z >= z_intercept )
%             actual_x = [actual_x data.Objects.X];
%             actual_y = [actual_y data.Objects.Y];
%             actual_z = [actual_z data.Objects.Z];
% 
%             data = receive(ou, 10);
%     end
% end

if DEV_ENVIRONMENT
    i = data_array(end)-50;
    while points(i).Objects.Z >= z_intercept
        i = i + 1;
        actual_x = [actual_x points(i).Objects.X];
        actual_y = [actual_y points(i).Objects.Y];
        actual_z = [actual_z points(i).Objects.Z];
        if i >= numel(points)
            break
        end
    end
else
    data = receive(ou, 10);
    while points(i).Objects.Z >= z_intercept
        data = receive(ou, 10);
    end
end

%Fit a curve after acquiring the rest of the data points
fit_xz_actual = polyfit(actual_x(stop_ptr:end)', actual_z(stop_ptr:end)', 2);
fit_yz_actual = polyfit(actual_y(stop_ptr:end)', actual_z(stop_ptr:end)', 2);

%Calculate the interception points for actual data
[x_intersect_actual, y_intersect_actual] = get_intersection(fit_xz_actual, fit_yz_actual, z_intercept);

if is_positive_direction_x
    x_intersect_actual = max(x_intersect_actual);
else
    x_intersect_actual = min(x_intersect_actual);
end

if is_positive_direction_y
    y_intersect_actual = max(y_intersect_actual);
else
    y_intersect_actual = min(y_intersect_actual);
end

disp("Actual X-intercept: ");
x_intersect_actual
disp("Actual Y-intercept: ");
y_intersect_actual

disp("Error in the x-prediction");
abs(x_intersect - x_intersect_actual)
disp("Error in the y-prediction");
abs(y_intersect - y_intersect_actual)

%% Plots
figure
% XZ
subplot(2, 3, 1)
%plot(sample_x, sample_z, '+b')
hold on
grid on
plot(x_points(1:stop_ptr), z_points(1:stop_ptr), '+r')

x1_xz = linspace(reflection_x(1), reflection_x(end), 1000);
y1_xz = polyval(fit_xz_reflection, x1_xz);
plot(x1_xz, y1_xz)

title('XZ')
legend('Actual points', 'Predicted fall', 'Location', 'south')

% YZ
subplot(2, 3, 4)
%plot(sample_y, sample_z, '+b')
hold on
grid on
plot(y_points(1:stop_ptr), z_points(1:stop_ptr), '+r')

x1_yz = linspace(reflection_y(1), reflection_y(end), 1000);
y1_yz = polyval(fit_yz_reflection, x1_yz);
plot(x1_yz, y1_yz)

title('YZ')
legend('Actual points', 'Predicted fall', 'Location', 'south')

% Actual XZ
subplot(2, 3, 2)
hold on
grid on
plot(actual_x, actual_z, '+r')

x1_xz_act = linspace(actual_x(stop_ptr), actual_x(end), 1000);
y1_xz_act = polyval(fit_xz_actual, x1_xz_act);
plot(x1_xz_act, y1_xz_act)

title('XZ actual data')
legend('Actual points', 'Interpolated actual fall', 'Location', 'south')

% Actual YZ
subplot(2, 3, 5)
%plot(sample_y, sample_z, '+b')
hold on
grid on
plot(actual_y, actual_z, '+r')

x1_yz_act = linspace(actual_y(stop_ptr), actual_y(end), 1000);
y1_yz_act = polyval(fit_yz_actual, x1_yz_act);
plot(x1_yz_act, y1_yz_act)

title('YZ actual data')
legend('Actual points', 'Interpolated actual fall', 'Location', 'south')

% Predicted over actual XZ
subplot(2, 3, 3)
hold on
grid on
plot(x_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
plot(x1_xz, y1_xz)
plot(x1_xz_act, y1_xz_act)

x1_xz_intercept = min(actual_x):max(actual_x);
y1_xz_intercept = z_intercept * ones(numel(x1_xz_intercept), 1);
plot(x1_xz_intercept, y1_xz_intercept, 'g')

title('Predicted vs Actual XZ')
legend('Rising edge', 'Predicted fall', 'Actual fall', 'Location', 'south')

% Predicted over actual YZ
subplot(2, 3, 6)
hold on
grid on
plot(y_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
plot(x1_yz, y1_yz)
plot(x1_yz_act, y1_yz_act)

x1_yz_intercept = min(actual_y):max(actual_y);
y1_yz_intercept = z_intercept * ones(numel(x1_yz_intercept), 1);
plot(x1_yz_intercept, y1_yz_intercept, 'g')

title('Predicted vs Actual YZ')
legend('Rising edge', 'Predicted fall', 'Actual fall', 'Location', 'south')



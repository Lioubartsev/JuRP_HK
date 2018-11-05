close all
clc

DEV_ENVIRONMENT = 1;
DEV_SAMPLE = 2;

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

%%

%Check to see if ball has been thrown in the air
if DEV_ENVIRONMENT
    i = 1;
    while points(i).Objects.Z < 400
        i = i + 1;
    end
    data_array = i:i+50;
else
    data = receive(ou, 10);
    while(data.Objects.Z < 400)
        data = receive(ou, 10)
    end
    data_array = 1:50
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
%% Fit curve trajectory

%Step 1: Fit curve through original data points
% fit_xz = polyfit(x_points', z_points', 2);
% fit_yz = polyfit(y_points', z_points', 2);

%Step 2: Get the points that go through the curve created in the previous step
%[polyfit_xz, polyfit_yz] = Fit_points(z_points, fit_xz, fit_yz ) 

%Step 3: Reflect those points about a point z
[reflection_x, reflection_y, reflection_z] = Mirror(x_points, y_points, z_points, xz_max, yz_max);

x_points = [x_points reflection_x];
y_points = [y_points reflection_y];
z_points = [z_points reflection_z];


% fit_xz_reflection = polyfit(reflection_x', reflection_z', 2);
% fit_yz_reflection = polyfit(reflection_y', reflection_z', 2);

%Step 4: Fit a curve through the reflected points
fit_xz_reflection = polyfit(reflection_x', reflection_z', 2);
fit_yz_reflection = polyfit(reflection_y', reflection_z', 2);

figure

plot(sample_x, sample_z, '+b')
hold on
grid on
%plot(x_points, z_points, '+r')
title('XZ')


x1 = linspace(reflection_x(1), 850, 1000);
y1 = polyval(fit_xz_reflection, x1);
plot(x1, y1)

% YZ
figure
plot(sample_y, sample_z, '+b')
hold on
grid on
%plot(y_points, z_points, '+r')
title('YZ')


x1 = linspace(reflection_y(1), -600, 1000);
y1 = polyval(fit_yz_reflection, x1);
plot(x1, y1)

[x_intersect, y_intersect] = get_intersection(fit_xz_reflection, fit_yz_reflection, 150)






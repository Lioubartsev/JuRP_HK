close all
rosshutdown
rosinit

rostopic list

rostopic info /object_update

ou = rossubscriber('/object_update')

x_points = []
y_points = []
z_points = []

%Check to see if ball has been thrown in the air
data = receive(ou, 10)
while(data.Objects.Z/10 < 40 )
    data = receive(ou, 10)
end

for i = 1:40
    data = receive(ou, 10)
    x_beforelast = 0;
    y_beforelast = 0;
    z_beforelast = 0;
    
    if(i > 1)
        x_beforelast = x_points(end);
        y_beforelast = y_points(end);
        z_beforelast = z_points(end);
    end
    x_points = [x_points data.Objects.X/10];
    y_points = [y_points data.Objects.Y/10];
    z_points = [z_points data.Objects.Z/10];
    
    if(z_points(end) - z_beforelast < 0)
        xz_max = x_beforelast;
        yz_max = y_beforelast;
        break;
    end
    
end
%% Fit curve trajectory

%Step 1: Fit curve through original data points
fit_xz = polyfit(x_points', z_points', 2);
fit_yz = polyfit(y_points', z_points', 2);

%Step 2: Get the points that go through the curve created in the previous step
[polyfit_xz, polyfit_yz] = Fit_points(z_points, fit_xz, fit_yz ) 

%Step 3: Reflect those points about a point z 
[reflection_x, reflection_y, reflection_z] = Mirror(polyfit_xz, polyfit_yz, z_points, xz_max, yz_max);
%[reflection_x, reflection_y, reflection_z] = Mirror(x_points, y_points, z_points, xz_max, yz_max);

x_points = [x_points reflection_x];
y_points = [y_points reflection_y];
z_points = [z_points reflection_z];


%fit_xz_reflection = polyfit(reflection_x', reflection_z', 2);
%fit_yz_reflection = polyfit(reflection_y', reflection_z', 2);

%Step 4: Fit a curve through the reflected points
fit_xz_reflection = polyfit(x_points', z_points', 2);
fit_yz_reflection = polyfit(y_points', z_points', 2);

close all
plot(x_points, z_points, '+r')
title('XZ')
hold on
grid on

x1 = linspace(x_points(1), x_points(end), 1000);
y1 = polyval(fit_xz, x1);
plot(x1, y1)

%Reflection curves
plot(reflection_x, reflection_z, '+b')
hold on
grid on

x1 = linspace(reflection_x(1), reflection_x(end), 1000);
y1 = polyval(fit_xz_reflection, x1);
plot(x1, y1)


% YZ
figure
plot(y_points, z_points, '+r')
title('YZ')
hold on
grid on

x1 = linspace(y_points(1), y_points(end), 1000);
y1 = polyval(fit_yz, x1);
plot(x1, y1)

%roots(fit_xz)



%%
%plot(x_points, z_points, '+')
%hold on

%figure
%plot(y_points, z_points, '+')
%hold on


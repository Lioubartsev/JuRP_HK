close all
rosshutdown
rosinit

rostopic list

rostopic info /object_update

ou = rossubscriber('/object_update')

x_points = []
y_points = []
z_points = []
%
%zzz= []
%for i =1:50
%    i
%zzz = [zzz data.Objects.Z/10];
%end
%zzz
data = receive(ou, 10)
while(data.Objects.Z/10 < 40 )
    data = receive(ou, 10)
end

for i = 1:40
    i;
    data = receive(ou, 10)
    if data.Objects.Z > 70
        x_points = [x_points data.Objects.X/10];
        y_points = [y_points data.Objects.Y/10];
        z_points = [z_points data.Objects.Z/10];
    end
    
end
%% Fit line
%p = fit(points', pointsz', ft);

fit_xz = polyfit(x_points', z_points', 2)
fit_yz = polyfit(y_points', z_points', 2)


close all
plot(x_points, z_points, '+r')
title('XZ')
hold on
grid on

x1 = linspace(x_points(1), x_points(end), 1000);
y1 = polyval(fit_xz, x1);
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

roots(fit_xz)

%%
%plot(x_points, z_points, '+')
%hold on

%figure
%plot(y_points, z_points, '+')
%hold on

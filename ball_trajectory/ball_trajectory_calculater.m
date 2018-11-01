%% Accumulate point

points = [1 2 4 8 16 16 40 60 100;
            1 2 3 4 5 6 7 8 9];
        
pointsz = [1 2 3 4 5 6 7 8 9];

x_points = points(1, :)
y_points = points(2, :)
z_points = pointsz

%% Fit line
%p = fit(points', pointsz', ft);

fit_xz = polyfit(x_points', z_points', 2)
fit_yz = polyfit(y_points', z_points', 2)


close all
plot(x_points, z_points, '+r')
hold on
grid on

x1 = linspace(x_points(1), x_points(end), 1000);
y1 = polyval(fit_xz, x1);
plot(x1, y1)

% YZ
figure
plot(y_points, z_points, '+r')
hold on
grid on

x1 = linspace(y_points(1), y_points(end), 1000);
y1 = polyval(fit_yz, x1);
plot(x1, y1)

%% Calculate catching position
% Ie. intersection between line and the plane Z = 0
fit_xz
fit_yz
%max(roots(p))
%% Send

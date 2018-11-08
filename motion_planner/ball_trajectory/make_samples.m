%% Make sample points
pause(2)

close all
rosshutdown
rosinit

rostopic list

rostopic info /object_update

ou = rossubscriber('/object_update')

x_points = []
y_points = []
z_points = []

points = []
t0 = datevec(now);
sample_time_rel = []
for i = 1:300
    i
    data = receive(ou, 10);
    points = [points data];
    t =  datevec(now);
    sample_time_rel = [sample_time_rel t(6)-t0(6)];
end

%%
close all
x_points = [];
y_points = [];
z_points = [];
for point = points
    x_points = [x_points point.Objects.X];
    y_points = [y_points point.Objects.Y];
    z_points = [z_points point.Objects.Z];
end
fig_xz = figure();
plot(x_points, z_points, '+')
title('X-Z plane')
movegui(fig_xz, 'center')

fig_yz = figure();
plot(y_points, z_points, '+')
title('y-Z plane')
movegui(fig_yz, 'east')

%%
n = '3';
%save(strcat('samples/sample', n, '.mat'), 'points', 'x_points', 'y_points', 'z_points', 'sample_time_rel')
%saveas(fig_xz, strcat('samples/s', n, '_xz'), 'jpg')
%saveas(fig_yz, strcat('samples/s', n, '_yz'), 'jpg')

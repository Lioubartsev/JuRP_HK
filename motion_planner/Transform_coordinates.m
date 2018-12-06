function [x_prediction y_prediction z_prediction] = Transform_coordinates(x_prediction, y_prediction, z_prediction)

%Two points corresponding to movement in only the y direction in the room
x_1 =   1007;
x_2 =   1002;
y_1 =   -363;
y_2 =   -240;

Origin_shift = [0.770 -0.138 0.382]'; %m
angle_shift = -atan((x_1-x_2)/(y_1-y_2));

rotation_matrix = [cos(angle_shift) -sin(angle_shift);
                    sin(angle_shift) cos(angle_shift)];

state_trgt = [x_prediction y_prediction z_prediction]' - Origin_shift;

J = rotation_matrix*state_trgt(1:2); %m
x_prediction = J(1);
y_prediction = J(2);
z_prediction = state_trgt(3);

end
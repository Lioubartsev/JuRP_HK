
%Origin relation between vicon and LQR
Origin_shift = [0.752  -0.122 0.343]'; %m

x_1 = 421;
x_2 = 419;
y_1 =  -376;
y_2 =  -214;

angle_shift = -atan((x_1-x_2)/(y_1-y_2));
%angle_shift = 0;

%angle_shift = deg2rad(5 )%2.1304

rotation_matrix = [cos(angle_shift) -sin(angle_shift);
                    sin(angle_shift) cos(angle_shift)];

%Vicon global coordinate of ball %slight above origin
x_prediction = -774 / 1000; %m
y_prediction = 1072 / 1000; %m
z_prediction  = 426 / 1000; %m %370

%elbow
x_prediction = 746 / 1000; %m
y_prediction = 306 / 1000; %m
z_prediction  = 378 / 1000; %m

%EE
%x_prediction = 826 / 1000; %m
%y_prediction = 760 / 1000; %m
%z_prediction  = 398 / 1000; %m

%q = [shoulder_pos_val upper_pos_val elbow_pos_val ]'; 


%state_trgt = [y_prediction x_prediction z_prediction]' - Origin_shift; %m
%state_trgt = diag([1 -1 1])*state_trgt *100 %cm

state_trgt = [x_prediction y_prediction z_prediction]' - Origin_shift; %m

J = rotation_matrix*[state_trgt(1) state_trgt(2)]'; %m
x_prediction = J(1);
y_prediction = J(2);
state_trgt(1) = x_prediction ;
state_trgt(2) = y_prediction ;

state_trgt = diag([1 1 1])*state_trgt *100 %cm

LQR = [6 89.5 7]

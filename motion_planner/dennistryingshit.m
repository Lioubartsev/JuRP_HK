rosshutdown
rosinit
upper_pos_ros = rossubscriber('/upper_pos');
upper_data = receive(upper_pos_ros, 10);
upper_pos = upper_data.Data;
%upper_pos = upper_pos *2*pi/(10*360);
%q = [-0.1 upper_pos 0]';

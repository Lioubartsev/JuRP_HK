%Simulate sending some values to the LQR instead of throwing the ball
%physically
%% Initilization of ROS
rosshutdown
rosinit

context.DEV_MODE = 1; 
context.Sim_mode = 1;
context.Stalker_mode = 1;

%subscribe to topics
context.ou = rossubscriber('/object_update');
shoulder_pos_ros = rossubscriber('/shoulder_pos');
upper_pos_ros = rossubscriber('/upper_pos');
elbow_pos_ros = rossubscriber('/elbow_pos');

%Set publishers 
shoulder_reference = rospublisher('/shoulder_reference', 'std_msgs/Int16');
shoulder_reference_msg = rosmessage(shoulder_reference);

upper_reference = rospublisher('/upper_reference', 'std_msgs/Int16');
upper_reference_msg = rosmessage(upper_reference);

elbow_reference = rospublisher('/elbow_reference', 'std_msgs/Int16');
elbow_reference_msg = rosmessage(elbow_reference);


%% Send initial values

shoulder_data = receive(shoulder_pos_ros, 10); 
shoulder_pos = shoulder_data.Data;  % Degrees * 10
shoulder_pos_val = (cast(shoulder_pos, 'double')-900) *2*pi/(10*360); % Radians

upper_data = receive(upper_pos_ros, 10); 
upper_pos = upper_data.Data;  % Degrees * 10
upper_pos_val = (cast(upper_pos, 'double')-0) *2*pi/(10*360); % Radians

elbow_data = receive(elbow_pos_ros, 10);
elbow_pos = elbow_data.Data;   %Degrees * 10
elbow_pos_val = (cast(elbow_pos, 'double')) *2*pi/(10*360); % Radians

%% Send the initial references for testing
%This is to ensure that the arm maintains that initial position before
%sending new values
    
shoulder_reference_msg.Data = shoulder_pos;
send(shoulder_reference, shoulder_reference_msg);

elbow_reference_msg.Data = elbow_pos;
send(elbow_reference, elbow_reference_msg);

upper_reference_msg.Data = upper_pos;
send(upper_reference, upper_reference_msg);
    

%% Send parameters to the LQR
q = [shoulder_pos_val upper_pos_val elbow_pos_val ]' %elbow_pos_val]';


%% Track the ball in the air space
if context.Stalker_mode 
    while(1)
        %% Receive current position of the arm
        shoulder_data = receive(shoulder_pos_ros, 10);
        shoulder_pos = shoulder_data.Data;  % Degrees * 10
        shoulder_pos_val = (cast(shoulder_pos, 'double')-900) *2*pi/(10*360); % Radians   
        
        upper_data = receive(upper_pos_ros, 10);
        upper_pos = upper_data.Data;  % Degrees * 10
        upper_pos_val = (cast(upper_pos, 'double')-0) *2*pi/(10*360); % Radians
        
        elbow_data = receive(elbow_pos_ros, 10);
        elbow_pos = elbow_data.Data;   %Degrees * 10
        elbow_pos_val = (cast(elbow_pos, 'double')) *2*pi/(10*360); % Radians    
        
        %% Send current position of arm as reference
        shoulder_reference_msg.Data = shoulder_pos;
        send(shoulder_reference, shoulder_reference_msg);
        
        upper_reference_msg.Data = upper_pos;
        send(upper_reference, upper_reference_msg);
        
        elbow_reference_msg.Data = elbow_pos;
        send(elbow_reference, elbow_reference_msg);
        
        q = [shoulder_pos_val upper_pos_val elbow_pos_val ]'
        q_makeloddehappyagain = q;
        
        %% Receive the position for the stalker to follow
        data = receive(context.ou, 10);
        x_prediction = data.Objects.X / 1000; %m
        y_prediction = data.Objects.Y / 1000; %m
        z_prediction = data.Objects.Z / 1000; %m
    
        [x_prediction, y_prediction, z_prediction] = Transform_coordinates(x_prediction, y_prediction, z_prediction); %m
        state_trgt = [x_prediction y_prediction z_prediction];
        
        [q_traj] = InvKinLQR(q, state_trgt, context);
        
        q_traj = q_traj * 10 * 360 / (2 * pi) ; % Angle * 10
        
        q_traj(1,:) = q_traj(1,:) + 900; %Angle in terms of the local encoder's angle system
    
        for i= 1:length(q_traj)-1
            shoulder_reference_msg.Data = q_traj(1, i);
            send(shoulder_reference, shoulder_reference_msg);

            upper_reference_msg.Data = q_traj(2, i);
            send(upper_reference, upper_reference_msg);

            elbow_reference_msg.Data = q_traj(3, i);
            send(elbow_reference, elbow_reference_msg);

            pause(0.05);
        end
    
    pause(5);
    
    end
else
    x_prediction = 130 / 1000 ;
    y_prediction = 1100 / 1000;
    z_prediction = 135 / 1000 ;
 
end

state_trgt = [y_prediction x_prediction z_prediction]' - Origin_shift;
state_trgt = diag([1 -1 1])*state_trgt;

[q_traj] = InvKinLQR(q, state_trgt, context);

q_traj = q_traj * 10 * 360 / (2 * pi) ;

q_traj(1,:) = q_traj(1,:) + 900;


for i= 1:length(q_traj)-1
    shoulder_reference_msg.Data = q_traj(1, i);
    send(shoulder_reference, shoulder_reference_msg);
    upper_reference_msg.Data = q_traj(2, i);
    send(upper_reference, upper_reference_msg);
    elbow_reference_msg.Data = q_traj(3, i);
    send(elbow_reference, elbow_reference_msg);

    pause(0.05); 
end

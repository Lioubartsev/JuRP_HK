function [q_traj] = InvKinLQR(q,state_trgt)
% INPUT: Current angles, Target state
% OUTPUT: Reference trajectories for all three joints.
%
% INVKINLQR takes input as (CurrentAngles, TargetState) both entered as
% 1x3 vectors and calculates the optimal trajectory for the end effector and
% returns a 3xn matrix. Each row represents reference trajectory for one
% joint (Shoulder;UpperArm;Elbow) and each column represents one iteration.

DEV_MODE.data = false;  % Run in development mode
DEV_MODE.plot = false; % with plots

% Inverse kinematics and LQ controller for JuRP-HK. The inverse kinematics
% are solved numerically using the an altered version of the LM algorithm.
% The system is linearized in each iteration using the jacobian, as
% part of the LM algorithm. The input for the final code will be absolute
% position of the EE and the calculated position where ball catching will
% take place. Output will consist of reference vectors that will be passed
% on to the low level PIDs.

% Angles and lengths are increasingly indexed with shoulder as base. The
% coordinate system for the base is defined as x - left/right, y -
% forwards/backwards, z - up/down.

% Link lengths [m]
l1 = 0.2;
l2 = 0.2;
l3 = 0.4;

% % Rotation matrix around x axis of the base
% Rx = @(theta) [1 0 0 0
%     0 cos(theta) -sin(theta) 0
%     0 sin(theta) cos(theta) 0
%     0 0 0 1];
% 
% % Rotation matrix around y axis of the base
% Ry = @(theta) [cos(theta) 0 sin(theta) 0
%     0 1 0 0
%     -sin(theta) 0 cos(theta) 0
%     0 0 0 1];
% 
% % Translation matrix
% T = @(l) [1 0 0 0
%     0 1 0 l
%     0 0 1 0
%     0 0 0 1];

% Translations for all links
T1 = [1 0 0 0; 0 1 0 l1;0 0 1 0;0 0 0 1];
T2 = [1 0 0 0; 0 1 0 l2;0 0 1 0;0 0 0 1];
T3 = [1 0 0 0; 0 1 0 l3;0 0 1 0;0 0 0 1];

% Homogenous transformation matrix from base to EE
%H04 = @(theta1,theta2,theta3) Rx(theta1)*T1*Ry(theta2)*T2*Rx(theta3)*T3;

H04 = @(theta1,theta2,theta3) [1 0 0 0; 0 cos(theta1) -sin(theta1) 0;...
    0 sin(theta1) cos(theta1) 0; 0 0 0 1]*T1*[cos(theta2) 0 sin(theta2)...
    0; 0 1 0 0; -sin(theta2) 0 cos(theta2) 0; 0 0 0 1]*T2*[1 0 0 0; 0 ...
    cos(theta3) -sin(theta3) 0; 0 sin(theta3) cos(theta3) 0; 0 0 0 1]*T3;

H03 = @(theta1,theta2) Rx(theta1)*T1*Ry(theta2)*T2;

% Jacobian matrix
% syms theta1 theta2 theta3 real
% J = jacobian(pos,[theta1,theta2,theta3]);
% J = matlabFunction(J);
J = @(theta1,theta2,theta3)reshape([0.0,-sin(theta1)-cos(theta3).*...
    sin(theta1)-cos(theta1).*cos(theta2).*sin(theta3),cos(theta1)+...
    cos(theta1).*cos(theta3)-cos(theta2).*sin(theta1).*sin(theta3),...
    cos(theta2).*sin(theta3),sin(theta1).*sin(theta2).*sin(theta3),...
    -cos(theta1).*sin(theta2).*sin(theta3),cos(theta3).*sin(theta2),...
    -cos(theta1).*sin(theta3)-cos(theta2).*cos(theta3).*sin(theta1),...
    -sin(theta1).*sin(theta3)+cos(theta1).*cos(theta2).*cos(theta3)],[3,3]);

% --- optimization part ---

% init for state ([x y z])
%q = deg2rad([0 0 0])';          % Init angles
H = H04(q(1),q(2),q(3));
state = H(1:3,4);
state_init = state;

% Desired position in absolute coordinates relative to base [m]
% state_trgt = [0.2 1.8 0.5]';
e = state_trgt - state;    % Error desried and actual pos

% Maximum number of iterations
maxIterations = 10000;
iterations = 1;
% Error tolerance for final EE pos norm [m]
tolerance = 0.01;
stepsize = 1/25;    % Error stepsize for linearization

% Coordinate initiation
x = zeros(1,maxIterations); y = zeros(1,maxIterations);
z = zeros(1,maxIterations); q_traj = zeros(3,maxIterations);

% Levenberg Marquardt algorithm aims to solve the minimization problem
% formulated as minimize(0.5*r'*We*r + 0.5*dQ'*Wn*dQ). Where dQ = Q(k+1) -
% Q(k) and r = e - J'*dQ (e is the error we want to minimize). This means
% that We is the cost-weight for the error and Wn is the cost-weight for
% the angle change.

% --- Weights and constraints ---
% Error weight, specifies what error is prioritized to minimize [x y z]
We = diag([1 3 2]);
% Damping factor init. Updated in the loop as a function of the error.
% Wn0 specifies weights for joint usage [Shoulder, upper arm, elbow]
Wn0 = diag(1.4*[1 1 1]);
% Joint limits (upper bound = lower bound) and joint limit weight
JointLim = deg2rad([95 45 110]'); % [Shoulder, upper arm, elbow]
Wl = diag(10*[1 1 1]);

while norm(e) > tolerance
    
    % Current position calculations
    H = H04(q(1),q(2),q(3));
    state = H(1:3,4);
    
    if DEV_MODE.data == true
        % Save pos for plot later
        x(iterations) = state(1); y(iterations) = state(2);
        z(iterations) = state(3);
    end
    
    q_traj(:,iterations) = q;
    
    Jacobian = J(q(1),q(2),q(3));   % Jacobian matrix
    
    %E = 0.5*diag(e')*We*diag(e);
    E = 0.5*e'*We*e*Wn0;
    Wn =  E + 2.5e-5*eye(3); % Wn = E + Wn_bias
    % ---------- Angle iteration ----------
    
    % Newton Raphson
    % q = q + Jacobian'*((desPos-curPos)/100);  % q(k+1) = q(k) + J'*e/step
    
    % Gauss Newton (NOT WORKING)
    % Jp = pinv(Jacobian);
    % gk = Jacobian'*We*((desPos-curPos)/1000);
    % q = q + Jp*gk;
    
    % Levenberg Marquardt
    lim = (diag(JointLim - abs(q)))'*Wl*(diag(JointLim - abs(q)));
    Hj = Jacobian'*We*Jacobian + Wn + lim^-1;
    gk = Jacobian'*We*((state_trgt-state)*stepsize);
    q = q + Hj^-1*gk;    % q(k+1) = q(k) + (J'We + Wn + lim^-1)^-1*J'We*e
    
    % q = q + (Jacobian'*We*Jacobian + Wn + ((diag(JointLim - abs(q)))'...
    %    *Wl*(diag(JointLim - abs(q))))^-1)^-1*(Jacobian'*We*...
    %    ((state_trgt-state)/100));
    % -------------------------------------
    
    % Error
    e = state_trgt - state;
    
    % Break Condition for max number of iterations
    if iterations > maxIterations
        disp('BreakCondReached')
        break;
    end
    iterations = iterations + 1;
end

% EE vector trim
x = x(1:iterations-1); y = y(1:iterations-1); z = z(1:iterations-1);
q_traj = q_traj(:,1:iterations-1);

% EE travel distance
if DEV_MODE.data == true
    psum = 0; xsum = 0; ysum = 0; zsum = 0;
    
    for n = 1:length(x)-1
        psum = psum + norm([x(n+1),y(n+1),z(n+1)] - [x(n),y(n),z(n)]);
        xsum = xsum + abs(x(n+1) - x(n));
        ysum = ysum + abs(y(n+1) - y(n));
        zsum = zsum + abs(z(n+1) - z(n));
    end
    
    disp(['Distance from goal: ',num2str(round(1000*norm(e),3)), ' mm'])
    disp(['Iterations: ', num2str(iterations-1)])
    disp(['Final EE pos: [',num2str([x(end),y(end),z(end)]), '] m'])
    disp(['Q: [',num2str(q'), '] rad'])
    disp(['EE travel distance: ', num2str(psum), ' m ...'])
    disp(['... in x ',num2str(xsum), ' m'])
    disp(['... in y ',num2str(ysum), ' m'])
    disp(['... in z ',num2str(zsum), ' m'])
    disp('--------------------------')
end

if DEV_MODE.plot == true
    % Plot/results section
    
    H3 = H03(q(1),q(2));
    elbowPos = H3(1:3,4);
    
    figure(1)
    plot3(x,y,z)
    grid on
    hold on
    plot3(state_init(1),state_init(2),state_init(3),'m*')
    plot3(state_trgt(1),state_trgt(2),state_trgt(3),'rO')
    plot3(x(end),y(end),z(end),'b+')
    line([0 elbowPos(1) state(1)],[0 elbowPos(2) state(2)],...
        [0 elbowPos(3) state(3)],'Color','k','LineWidth',2);
    
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    title('EE movment in 3D space')
    legend('EE trajectory','Start Pos','Desired Pos', 'Final EE pos')
    axis([-0.8 0.8 0 1.6 -0.8 0.8])
    
    figure(2)
    subplot(3,2,1)
    title('Position for EE devided into X Y Z [m]')
    hold on
    h = line([1 length(x)],[state_trgt(1) state_trgt(1)]);
    h.LineStyle = '--';
    plot(x)
    ylabel('X')
    grid on
    
    subplot(3,2,3)
    hold on
    h = line([1 length(y)],[state_trgt(2) state_trgt(2)]);
    h.LineStyle = '--';
    plot(y)
    ylabel('Y')
    grid on
    
    subplot(3,2,5)
    hold on
    h = line([1 length(z)],[state_trgt(3) state_trgt(3)]);
    h.LineStyle = '--';
    plot(z)
    ylabel('Z')
    xlabel('Iterations')
    grid on
    
    subplot(3,2,[2 4 6])
    hold on
    grid on
    plot(rad2deg(q_traj(1,:)))
    plot(rad2deg(q_traj(2,:)))
    plot(rad2deg(q_traj(3,:)))
    legend('Shoulder','Upper Arm','Elbow')
    title('Angle reference for all joints')
    ylabel('Angle [deg]')
    xlabel('Iterations')
end
% TODO:
% - Needs citing/ references in order to make report writing easier.
% - fix error so that we can punish big angle changes
% - chech bryson for Wn

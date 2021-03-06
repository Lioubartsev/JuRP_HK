function [x_intersect, y_intersect] = ball_trajectory_calculater(context)


    if context.DEV_ENVIRONMENT
        load(strcat('samples/sample', int2str(context.DEV_SAMPLE), '.mat'))
        sample_x = x_points;
        sample_y = y_points;
        sample_z = z_points;
    else
        % Do nothing
    end

    %% Visualize throw
    % figure
    % 
    % plot(sample_x(1), sample_z(1))
    % hold on
    % for i = 2:numel(sample_z)
    %     plot(sample_x(i), sample_z(i), '+')
    %     hold on
    %     pause(0.05)
    %     sample_z(i)
    % end

    %% Collect data points
    
    if context.DEV_ENVIRONMENT
        i = 1;
        while points(i).Objects.Z/1000 < context.z_threshold
            i = i + 1;
        end
        
        %data_array = i:i+50;
        data_ptr = i;
    else
        %fprintf("Waiting for throw...\n\n")        
        data_ptr = 1;
        data = receive(context.ou, 10);
        while(data.Objects.Z/1000 < context.z_threshold)
            data = receive(context.ou, 10);
        end
        %data_array = 1:50;
    end
    
    t0 = datenummx(clock);
    t_stamp = [];
    
    %Method 1
    if context.method == 1
        
        x_points = [];
        y_points = [];
        z_points = [];
        
        data_array = data_ptr:data_ptr+50;
        for i = data_array
            if context.DEV_ENVIRONMENT
                data = points(i);
            else
                data = receive(context.ou, 10);
            end
            
            if length(z_points)>1 && (data.Objects.Z/1000 - z_points(end)) < 0
                xz_max = x_points(end);
                yz_max = y_points(end);
                break
            else
                t1 = clock - t0;
                t_stamp = [t_stamp t1(6)];
                
                x_points = [x_points data.Objects.X/1000];
                y_points = [y_points data.Objects.Y/1000];
                z_points = [z_points data.Objects.Z/1000];
            end
            
        end
          
    else
    % Method 2
        data_array = data_ptr:data_ptr+context.length_sample;
        
        x_points = zeros(1, context.length_sample);
        y_points = zeros(1, context.length_sample);
        z_points = zeros(1, context.length_sample);
        
        vx = zeros(1, context.length_sample-1);
        vy = zeros(1, context.length_sample-1);
        us = zeros(1, context.length_sample-1);
        
        for i = data_array
             j = i - data_ptr+1;
            
            if context.DEV_ENVIRONMENT == 0
                data = receive(context.ou, 10);
            else
                data = points(i);
            end
            
            x_points(j) = data.Objects.X/1000;
            y_points(j) = data.Objects.Y/1000;
            z_points(j) = data.Objects.Z/1000;
            
             if j > 1
                 
                vx(j-1) = (x_points(j)-x_points(j-1))*context.fs;
                vy(j-1) = (y_points(j)-y_points(j-1))*context.fs;
                us(j-1) = 1/context.fs*i*9.81+(z_points(j)-z_points(j-1))*context.fs;
                
%                 v_average_x = mean(vx);
%                 v_average_y = mean(vy);
%                 v_average_z = mean(us);
                
%                 v_median_x = median(vx(end-5:end));
%                 v_median_y = median(vy(end-5:end));
%                 v_median_z = median(us(end-5:end));
                
                %delta_t = [delta_t t_stamp(j)-t_stamp(j-1)];
             end
        end
        
        v_median_x = median(vx);
        v_median_y = median(vy);
        v_median_z = median(us);
        
        g = -9.81;
        %z_max_average = -v_average_z^2/(2*g)+z_points(1)
        z_max_median = -v_median_z^2/(2*g)+z_points(1)
    end

    % Store a copy of the actual data points before manipulation
    actual_x = x_points;
    actual_y = y_points;
    actual_z = z_points;

    %% Fit curve trajectory
    
    %Method 1
    if context.method == 1
        % Step 1: Reflect points about the maximum z-point
        [reflection_x, reflection_y, reflection_z] = Mirror(x_points, y_points, z_points, xz_max, yz_max);

        x_points = [x_points reflection_x];
        y_points = [y_points reflection_y];
        z_points = [z_points reflection_z];

        % Step 3: Fit a curve through the reflected points
        fit_xz_reflection = polyfit(reflection_x', reflection_z', 2);
        fit_yz_reflection = polyfit(reflection_y', reflection_z', 2);
        
    else
    % Method 2 
    
       %px = polyfit(x_points, z_points, 1);
       %py = polyfit(y_points, z_points, 1);
       
    end
    
    %Determine the direction of ball throw
    if x_points(1) < x_points(end)
        is_positive_direction_x = 1;
    else
        is_positive_direction_x = 0;
    end
    
    if y_points(1) < y_points(end)
        is_positive_direction_y = 1;
    else
        is_positive_direction_y = 0;
    end

    %% Calculate the interception points

    %Method 1
    if context.method == 1
        [x_intersect, y_intersect] = get_intersection(fit_xz_reflection, fit_yz_reflection, context.z_intercept);

        %Check the direction of ball throw
        if is_positive_direction_x
            x_intersect = max(x_intersect);
        else
            x_intersect = min(x_intersect);
        end

        if is_positive_direction_y
            y_intersect = max(y_intersect);
        else
            y_intersect = min(y_intersect);
        end
        
    else
    %Method 2   
    
%        zx = polyval(px, x_points(end));
%        zy = polyval(px, y_points(end));
%        alpha_x = atan(zx/x_points(end));
%        alpha_y = atan(zy/y_points(end));     
%        delta_t = 1/context.fs;
%        v_xs = 1:9;
%        v_ys = 1:9;
%        for i = 1:9
%            v_xs(i) = (x_points(i+1)-x_points(i))/delta_t;
%            v_ys(i) = (y_points(i+1)-y_points(i))/delta_t;
%        end  
%        v_0x = mean(v_xs);
%        v_0y = mean(v_ys);
%        t_end = abs(2*v_0x*sin(alpha_x)/g);
%        x_intersect = v_0x * t_end * cos(alpha_x);
%        y_intersect = v_0y * t_end * cos(alpha_y);

       g = -9.81;
       z_delta = context.z_threshold - z_points(1);
       
       %t_end = max(roots([1 2/g*v_average_z -(2/g)*z_delta]));
       t_end = max(roots([1 2/g*v_median_z -(2/g)*z_delta]));

       %x_intersect = v_average_x * t_end + x_points(1);
       %y_intersect = v_average_y * t_end + y_points(1) ;
       
       x_intersect = v_median_x * t_end + x_points(1) ;
       y_intersect = v_median_y * t_end + y_points(1) ;
       
       % Calculate catching velocity
       v_z = sqrt(v_median_z^2 + (2)*(g)*(z_delta));
    end
    
    % if DEV_ENVIRONMENT
    %     % Do nothing
    % else
    %    reference_update_msg.Data = strcat(num2str(x_intersect), ';', num2str(y_intersect));
    %    send(cr, reference_update_msg) 
    % end
 
    
    %% Continue sampling the actual data points

    if context.DEV_MODE
            
        if context.DEV_ENVIRONMENT
            i = data_array(end)-50;
            while points(i).Objects.Z/1000 >= context.z_intercept
                i = i + 1;
                actual_x = [actual_x points(i).Objects.X/1000];
                actual_y = [actual_y points(i).Objects.Y/1000];
                actual_z = [actual_z points(i).Objects.Z/1000];
                if i >= numel(points)
                    break
                end
            end
        else
            data = receive(context.ou, 10);
            while data.Objects.Z/1000 >= context.z_intercept
                data = receive(context.ou, 10);
                actual_x = [actual_x data.Objects.X/1000];
                actual_y = [actual_y data.Objects.Y/1000];
                actual_z = [actual_z data.Objects.Z/1000];
            end
        end
        
        %Fit a curve after acquiring the rest of the data points
        %fit_xz_actual = polyfit(actual_x(stop_ptr:end)', actual_z(stop_ptr:end)', 2);
        %fit_yz_actual = polyfit(actual_y(stop_ptr:end)', actual_z(stop_ptr:end)', 2);
        
        stop_ptr = numel(actual_x)-10;
        
        fit_xz_actual = polyfit(actual_x(stop_ptr:end)', actual_z(stop_ptr:end)', 2);
        fit_yz_actual = polyfit(actual_y(stop_ptr:end)', actual_z(stop_ptr:end)', 2);
        
        %Calculate the interception points for actual data
        [x_intersect_actual, y_intersect_actual] = get_intersection(fit_xz_actual, fit_yz_actual, context.z_intercept);
        
        if is_positive_direction_x
            x_intersect_actual = max(x_intersect_actual);
        else
            x_intersect_actual = min(x_intersect_actual);
        end
        
        if is_positive_direction_y
            y_intersect_actual = max(y_intersect_actual);
        else
            y_intersect_actual = min(y_intersect_actual);
        end
        
        %Print values on the screen
        
        %fprintf('Predicted X-intercept using average: %g m.\n', x_intersect);
        %fprintf('Predicted Y-intercept using average: %g m.\n\n', y_intersect);
        
        fprintf('Predicted X-intecept using median: %g m.\n', x_intersect);
        fprintf('Predicted Y-intercept using median: %g m.\n\n', y_intersect);
        
        fprintf('Actual X-intercept: %g m.\n', x_intersect_actual);
        fprintf('Actual Y-intercept: %g m.\n\n', y_intersect_actual);
        
        %fprintf('Error in the x-prediction using average: %g m.\n', abs(x_intersect - x_intersect_actual));
        %fprintf('Error in the y-prediction using average: %g m.\n\n', abs(y_intersect - y_intersect_actual));
        
        fprintf('Error in the x-prediction using median: %g cm.\n', abs(x_intersect - x_intersect_actual)*100);
        fprintf('Error in the y-prediction using median: %g cm.\n\n', abs(y_intersect - y_intersect_actual)*100);
    
    end

    %% Plots
    
    if context.DEV_MODE
        
        if context.method == 1
            
            figure
            %% XZ
            subplot(2, 3, 1)
            hold on
            grid on
            plot(x_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
            
            x1_xz = linspace(reflection_x(1), reflection_x(end), 1000);
            y1_xz = polyval(fit_xz_reflection, x1_xz);
            plot(x1_xz, y1_xz)
            
            title('XZ')
            legend('Actual points', 'Predicted fall', 'Location', 'south')
            
            %% YZ
            subplot(2, 3, 4)
            hold on
            grid on
            plot(y_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
            
            x1_yz = linspace(reflection_y(1), reflection_y(end), 1000);
            y1_yz = polyval(fit_yz_reflection, x1_yz);
            plot(x1_yz, y1_yz)
            
            title('YZ')
            legend('Actual points', 'Predicted fall', 'Location', 'south')
        else
            %Do Nothing
        end
          
         actual_x = actual_x * 100;
         actual_y = actual_y * 100;
         actual_z = actual_z * 100;
        
        %% Actual XZ
        subplot(2, 3, 2)
        hold on
        grid on
        plot(actual_x, actual_z, '+r')
        
%         x1_xz_act = linspace(actual_x(stop_ptr), actual_x(end), 1000);
%         y1_xz_act = polyval(fit_xz_actual, x1_xz_act);
%         plot(x1_xz_act, y1_xz_act)
%         
        title('XZ actual data')
        legend('Actual points', 'Interpolated actual fall', 'Location', 'south')
        
        %% Actual YZ
        subplot(2, 3, 5)
        hold on
        grid on
        plot(actual_y, actual_z, '+r')
%         
%         x1_yz_act = linspace(actual_y(stop_ptr), actual_y(end), 1000);
%         y1_yz_act = polyval(fit_yz_actual, x1_yz_act);
%         plot(x1_yz_act, y1_yz_act)
%         
        title('YZ actual data')
        legend('Actual points', 'Interpolated actual fall', 'Location', 'south')
        
        %% Predicted over actual XZ
%         subplot(2, 3, 3)
%         hold on
%         grid on
%         plot(x_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
%         plot(x1_xz, y1_xz)
%         plot(x1_xz_act, y1_xz_act)
%         
%         x1_xz_intercept = min(actual_x):max(actual_x);
%         y1_xz_intercept = context.z_intercept * ones(numel(x1_xz_intercept), 1);
%         plot(x1_xz_intercept, y1_xz_intercept, 'g')
%         
%         title('Predicted vs Actual XZ')
%         legend('Rising edge', 'Predicted fall', 'Actual fall', 'Location', 'south')
        
        %% Predicted over actual YZ
%         subplot(2, 3, 6)
%         hold on
%         grid on
%         plot(y_points(1:stop_ptr), z_points(1:stop_ptr), '+r')
%         plot(x1_yz, y1_yz)
%         plot(x1_yz_act, y1_yz_act)
%         
%         x1_yz_intercept = min(actual_y):max(actual_y);
%         y1_yz_intercept = context.z_intercept * ones(numel(x1_yz_intercept), 1);
%         plot(x1_yz_intercept, y1_yz_intercept, 'g')
%         
%         title('Predicted vs Actual YZ')
%         legend('Rising edge', 'Predicted fall', 'Actual fall', 'Location', 'south')
    end

    
    
    
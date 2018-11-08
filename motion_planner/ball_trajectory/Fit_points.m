function [fit_x, fit_y] = Fit_points(z_points, fit_xz, fit_yz)
    %fit_z_xz = []
    %fit_z_yz = []
    
    fit_x = []
    fit_y = []
    for i = 1:numel(z_points)
       %fit_z_xz = [fit_z_xz fit_xz(1)*x_points(i)*x_points(i) + fit_xz(2)*x_points(i)+fit_xz(3)]
       %fit_z_yz = [fit_z_yz fit_yz(1)*y_points(i)*y_points(i) + fit_yz(2)*y_points(i)+fit_yz(3)]
        
       fit_x = [fit_x max(real(roots(fit_xz-z_points(i))))];
       fit_y = [fit_y max(real(roots(fit_yz-z_points(i))))];
    
    
    end


end
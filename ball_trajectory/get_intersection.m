function [x_intersect, y_intersect] = get_intersection(poly_xz, poly_yz, z_plane)
    %fit_z_xz = [fit_z_xz fit_xz(1)*x_points(i)*x_points(i) + fit_xz(2)*x_points(i)+fit_xz(3)]
    %fit_z_yz = [fit_z_yz fit_yz(1)*y_points(i)*y_points(i) + fit_yz(2)*y_points(i)+fit_yz(3)]
    poly_xz(end) = poly_xz(end)-z_plane;
    poly_yz(end) = poly_yz(end)-z_plane;
    
    x_intersect = roots(poly_xz);
    y_intersect = roots(poly_yz);
end
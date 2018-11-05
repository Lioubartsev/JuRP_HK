function [reflection_x, reflection_y, reflection_z] = Mirror(x_points, y_points, z_points, z_plane_x, z_plane_y)
reflection_x = []
reflection_y = []
reflection_z = []

for i = 1:numel(x_points)
    
   reflection_x = [reflection_x z_plane_x*2-x_points(i)]
   reflection_y = [reflection_y z_plane_y*2-y_points(i)]
   reflection_z = [reflection_z z_points(i)]
    
end




end
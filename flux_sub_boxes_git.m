%%% Function information

% Function to divide glacier flux boxes cross-glacier into 50 m
% longitudinal segments

% INPUTS:
    % Raster image of debris thickness (.tif)
    % Shapefile of center flow line
    % Shapefile of flux boxes

% Notes:
    % Each flowline 'segment' **must** correspond to a flux box.

%%% MAIN SCRIPT %%%


% Input shape files
box_file_name = "Rongbuk_West_Flux_Boxes.shp";
flow_file_name = 'Rongbuk_West_Center_Line.shp';
boxes_shapes = shaperead(box_file_name);
flowline = shaperead(flow_file_name);


figure;

for box = 1:length(boxes_shapes)
    % flow line vector for the specific box
    box_flowline = [flowline.X(box) flowline.Y(box); flowline.X(box + 1) flowline.Y(box + 1)];
    box_flowline_lon = box_flowline(:,1);
    box_flowline_lat = box_flowline(:,2);


    % box coords
    box_lon = boxes_shapes(box).X;
    box_lon(end-1:end) = [];
    box_lat = boxes_shapes(box).Y;
    box_lat(end-1:end) = [];

    if length(box_lon) > 4 % only consider quadrilaterals 
        continue
    end

    centroid_lon = mean(box_flowline_lon);
    centroid_lat = mean(box_flowline_lat);


    %  datum where centroid is (0,0)
    box_lon = box_lon - centroid_lon;
    box_lat = box_lat - centroid_lat;
    box_flowline_lon = box_flowline_lon - centroid_lon;
    box_flowline_lat = box_flowline_lat - centroid_lat;

    % convert to m
    box_ym = box_lat * 111000;
    box_xm = box_lon .* (111000 * cosd(centroid_lat));

    box_flowline_ym = box_flowline_lat * 111000;
    box_flowline_xm = box_flowline_lon .* (111000 * cosd(centroid_lat));


    % calculate angle to rotate (angle between flow line and north)
    theta = atan2(box_flowline_ym(1), box_flowline_xm(1)) - pi/2 ;

    % rotate all box points to new datum where flowline is y 
    rotation_matrix1 = [cos(-theta), -sin(-theta);
                       sin(-theta), cos(-theta)];
    rotation_matrix2 = [cos(theta), -sin(theta);
                       sin(theta), cos(theta)];

    points_datum = rotation_matrix1 * [box_xm; box_ym];
    flowline_datum = rotation_matrix1 * [box_flowline_xm'; box_flowline_ym'];

    shape = polyshape(points_datum(1,:), points_datum(2,:));
    axis equal
    hold on
    % plot(shape)
    % plot(flowline_datum(1,:), flowline_datum(2,:))

    % calculate angles in order to find order of points
    angles = atan2d(points_datum(2,:), points_datum(1,:));

    % sort angles
    [~, idx] = sort(angles, 'descend');
    points_datum = points_datum(:,idx);

    % add segments - calculate how many segment will fit based on the
    % min / max of the overall flux box

    segment_width = 50;
    mean_heights = [];
    segment_x = [];
    for segment_number = floor(max(points_datum(1,1), points_datum(1,4)) / segment_width) + 2: floor(min(points_datum(1,2), points_datum(1,3)) / segment_width)
        segment = [((segment_number - 1) * segment_width), ((segment_number*segment_width)), ((segment_number*segment_width)), ((segment_number - 1) * segment_width);
                   top_line((segment_number - 1) * segment_width, points_datum), top_line((segment_number*segment_width), points_datum), bottom_line((segment_number*segment_width), points_datum), bottom_line((segment_number - 1) * segment_width, points_datum)];
        segment_x(end + 1) = (segment_number * segment_width) - 15;
        % rotate back
        segment = rotation_matrix2 * segment;
        % convert back to deg
        segment(2,:) = segment(2,:) ./ 111000;
        segment(1,:) = segment(1,:) ./ (111000 * cosd(centroid_lat));
        % return back to pos
        segment(2,:) = segment(2,:) + centroid_lat;
        segment(1,:) = segment(1,:) + centroid_lon;

        plot(polyshape(segment(1,:), segment(2,:)))

    end

end


% y = m(x-x1) + y-y1
function y = top_line(x, points_datum)
    y = ((points_datum(2,1) - points_datum(2,2)) / (points_datum(1,1) - points_datum(1,2))) * (x-points_datum(1,1)) + points_datum(2,1); 
end
function y = bottom_line(x, points_datum)
    y = ((points_datum(2,3) - points_datum(2,4)) / (points_datum(1,3) - points_datum(1,4))) * (x-points_datum(1,3)) + points_datum(2,3); 
end

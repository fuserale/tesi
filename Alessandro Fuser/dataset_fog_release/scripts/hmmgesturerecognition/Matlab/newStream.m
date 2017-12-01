% Gesture recognition with Matlab.
% Copyright (C) 2008  Thomas Holleczek, ETH Zurich
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function x = newStream()


global buffer_len;

global out_buffer;
global out_buffer_update_rate;
global out_buffer_period;
global out_buffer_len;
global out_buffer_ctr;
global out_buffer_mag;

global large_buffer;
global large_buffer_update_rate;
global large_buffer_len;
global large_buffer_ind;
global discretized_buffer;

global baseline;
global feature_count;
global int_width;
global feature_count_mag;
global int_width_mag;

global axes_signal;
global axes_mag;
global axes_classification;
global axes_image;

% array containing axes handles of recorded gestures
% reset after every successful training step
global axes_training;

% global data structure holding recorded and discretized data
% needed for communication with infinite loop
global recorded_gesture;
recorded_gesture.recorded_data = cell(1,1);
recorded_gesture.discretized_data = cell(1,1);

global gesture_rest_position;


global ENERGY_TH;
global DISTANCE_TH;
global CLASSIFICATION;
global TRAINING;
global window_size;
global window_offset;

global sensor;
global sensor_src;
global baud_rate;

global main_gui;

global TERMINATE;

global ACTIVE_SENSOR;



% plot data initially ...
plot_buffer = out_buffer';
axes(axes_signal);
plot(plot_buffer);
title(axes_signal, 'x/y/z signals');
xlabel(axes_signal, 'time');
ylabel(axes_signal, 'a [mg]');


plot_buffer_mag = out_buffer_mag';
axes(axes_mag);
plot(plot_buffer_mag);
title(axes_mag, 'magnitude');
xlabel(axes_mag, 'time');
ylabel(axes_mag, 'a [mg]');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sensor setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up sensor (this was used for bluetooth sensor)
%system(sprintf('stty -F %s %d raw', sensor_src, baud_rate));
%system(sprintf('stty -F %s', sensor_src));

% pause to allow Bluetooth setup! (not needed for USB sensor)
%pause(2);


% open sensor (this works for Windows and Linux!)
sensor = serial(sensor_src);
set(sensor,'BaudRate',baud_rate);

fopen(sensor);

% sensor is now active
ACTIVE_SENSOR = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare input buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load buffer initially
buffer = fread(sensor, buffer_len, 'int8');

% transpose buffer
buffer = buffer';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% infinite loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% flag indicating whether the user is currently in a rest position or not
restPosition = 1;

% number of iterations left until new sliding window has to be evaluated
to_go = 0;


% buffer index of start of gesture
gesture_start_ind = 0;

% buffer index of end of gesture
gesture_end_ind = 0;

% start index of gesture in output buffer
gesture_out_start = 0;

% end index of gesture in output buffer
gesture_out_end = 0;


% init line counter
i = 0;

while (~TERMINATE)
    
    
    i = i + 1;

    
    % synchronize data stream, i.e. find prefix 'DX1' or 'DX3'
    while (~(buffer(1) == 'D' && buffer(2) == 'X' && (buffer(3) == '1' || buffer(3) == '3')))
        buffer = shiftLeft(buffer, 1);
        buffer(buffer_len) = fread(sensor, 1, 'int8');
    end

    % get data from stream
    id = fread(sensor, 1, 'int8');
    if (buffer(3) == '3') % This format ('DX3') is usually used for USB sensor
        button = fread(sensor, 1, 'int8');
        x_u = fread(sensor, 1, 'int16');
        y_u = fread(sensor, 1, 'int16');
        z_u = fread(sensor, 1, 'int16');
    elseif (buffer(3) == '1') % This format ('DX1') is usually used for Bluetooth sensor
        button = fread(sensor, 1, 'int16');
        x_u = 0; y_u = 0; z_u = 0;
    end

    x = fread(sensor, 1, 'int16');
    x = cast(x, 'double');
    y = fread(sensor, 1, 'int16');
    y = cast(y, 'double');
    z = fread(sensor, 1, 'int16');
    z = cast(z, 'double');
    mag = sqrt(x * x + y * y + z * z);
    mag = cast(mag, 'double');
    
    if (abs(x) > 6000 || abs(y) > 6000 || abs(z) > 6000)
        
        fprintf(1, 'ERROR: %d, %d, %d, %d, %d, %d, %d, %d, %d\n', i, id, button, x_u, y_u, z_u, x, y, z);
        
        % drop first character in buffer
        buffer = shiftLeft(buffer, 1);
        buffer(buffer_len) = fread(sensor, 1, 'int8');
        
        continue;
        
    end

    
      % update output buffer
%     if (out_buffer_ctr < out_buffer_len)
%         out_buffer_ctr = out_buffer_ctr + 1;
%     else
%         out_buffer(1,:) = shiftLeft(out_buffer(1,:), 1);
%         out_buffer(2,:) = shiftLeft(out_buffer(2,:), 1);
%         out_buffer(3,:) = shiftLeft(out_buffer(3,:), 1);
%         
%         out_buffer_mag(1,:) = shiftLeft(out_buffer_mag(1,:), 1);
%     end
  
    out_buffer(1,:) = shiftLeft(out_buffer(1,:), 1);
    out_buffer(2,:) = shiftLeft(out_buffer(2,:), 1);
    out_buffer(3,:) = shiftLeft(out_buffer(3,:), 1);
    out_buffer_mag(1,:) = shiftLeft(out_buffer_mag(1,:), 1);

    
    out_buffer(1, out_buffer_ctr) = x;
    out_buffer(2, out_buffer_ctr) = y;
    out_buffer(3, out_buffer_ctr) = z;
    out_buffer_mag(1, out_buffer_ctr) = mag;
   
    
    % update large buffer
    large_buffer_ind = new_buffer_index(large_buffer_ind, large_buffer_len, 1, 0);
     
    large_buffer(1, large_buffer_ind) = x;
    large_buffer(2, large_buffer_ind) = y;
    large_buffer(3, large_buffer_ind) = z;
    large_buffer(4, large_buffer_ind) = mag;
    
    % update discretized buffer
    discretized_buffer(1, large_buffer_ind) = discretize(x, baseline, feature_count, int_width);
    discretized_buffer(2, large_buffer_ind) = discretize(y, baseline, feature_count, int_width);
    discretized_buffer(3, large_buffer_ind) = discretize(z, baseline, feature_count, int_width);
    discretized_buffer(4, large_buffer_ind) = discretizePositive(mag, feature_count_mag, int_width_mag);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % classification
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (CLASSIFICATION || TRAINING)
        
        
        global gestures;
        global classification_gui;
        
  
           
        if (to_go == 0) % evaluate current sliding window
            
            % get window indices in large buffer
            window_end = large_buffer_ind;
                        
            
            % !!!
            % when using sensor Bluetooth 6, 8 and 9, the function call
            % fails as -window_size is interpreted as UNSIGNED!
            % WHY?
            % !!!
            %window_start = new_buffer_index(large_buffer_ind, large_buffer_len, offset, 0);
            window_start = mod( (large_buffer_ind - 1 - window_size), large_buffer_len) + 1;
            
        
            % get contents of window
            window = extract_from_buffer(large_buffer(4,:), window_start, window_end);
            window_x = extract_from_buffer(large_buffer(1,:), window_start, window_end);
            window_y = extract_from_buffer(large_buffer(2,:), window_start, window_end);
            window_z = extract_from_buffer(large_buffer(3,:), window_start, window_end);
            
            % determine energy
            energy = var(window);
            fprintf(1, 'ENERGY: %f\n', energy);
            
            threshold = energy;
            THRESHOLD = ENERGY_TH;
            
           
            if (gesture_rest_position(1) ~= -Inf)
                
                % determine distance to rest position if applicable
                % use distance for segmentation decision
                len = size(window);
                len = len(2);
                
                u = zeros(1,len);
                u = u + 1;

                dist_x = norm(window_x - u * gesture_rest_position(1,1));
                dist_y = norm(window_y - u * gesture_rest_position(1,2));
                dist_z = norm(window_z - u * gesture_rest_position(1,3));
                threshold = dist_x + dist_y + dist_z;
                
                fprintf(1, 'SUM(DIST): %f\n', threshold);
                
                THRESHOLD = DISTANCE_TH;
                
            end
            
            
            
            % find out if a restPosition change occurred
            if (threshold >= THRESHOLD && restPosition)
                
                % start of gesture
                restPosition = 0;
                gesture_start_ind = large_buffer_ind;
              
                gesture_out_start = out_buffer_ctr;
                gesture_out_end = out_buffer_ctr;
                
                if (CLASSIFICATION)
                
                    % update status in classification window
                    handles = guihandles(classification_gui);
                    set(handles.status, 'String', 'gesture');
                
                elseif (TRAINING)
                    % nothing
                end
             
            elseif (threshold < THRESHOLD && ~restPosition)
                
                % end of gesture
                restPosition = 1;
                gesture_end_ind = large_buffer_ind;
                
                gesture_out_end = out_buffer_ctr;
                
                % extract discretized gesture signals from buffer
                current_gesture = cell(4,1);
                for k = 1:4
                    current_gesture{k, 1} = extract_from_buffer(discretized_buffer(k,:), gesture_start_ind, gesture_end_ind);
                end
                
                % plot recorded gesture
                len = mod(gesture_end_ind - gesture_start_ind, large_buffer_len) + 1;
                recorded_data = zeros(3, len);
                for k = 1:4
                    recorded_data(k,:) = extract_from_buffer(large_buffer(k,:), gesture_start_ind, gesture_end_ind);
                end
                
                plotData = recorded_data(1:3,:);
                
                if (TRAINING)
                    
                    plot(axes_training(TRAINING), plotData', 'LineWidth', 2);
                    
                    for k = 1:4
                        recorded_gesture.recorded_data{TRAINING, k} = recorded_data(k,:);
                        recorded_gesture.discretized_data{TRAINING, k} = current_gesture{k, 1};
                    end
                    
                    TRAINING = 0;
                    
                elseif (CLASSIFICATION)
                    
                    [winner, winner_mag, LL] = classify(current_gesture);
                    handles = guihandles(classification_gui);
                    set(handles.LL, 'Data', LL);

                    if (winner_mag == 0)
                        name = 'n.a.';
                    else
                        g = gestures{1, winner_mag};
                        name = g.Name;
                    end

                    set(handles.result_mag, 'String', name);

                    if (winner == 0)
                        name = 'n.a.';
                    else
                        g = gestures{1, winner};
                        name = g.Name;
                        
                        plot(axes_classification, plotData', 'LineWidth', 2);
                        
                    end

                    set(handles.result_xyz, 'String', name);

                    % update status in classification window
                    set(handles.status, 'String', 'rest');
                    
                    % DISPLAY IMAGE
%                     image_name = sprintf('images/%s.jpg', name);
%                     RGB = imread(image_name);
%                     image(RGB, 'Parent', axes_image);
 
                    % call classification callback script
                    callback_classification(winner, winner_mag);
                    

                end
                
     
                
            else
                % nothing
            end

            
            % reset count-down
            to_go = window_offset;
        else
            to_go = to_go - 1;
        end
        
    end
    
    
    
    % print only a fraction of the measured values
    if (mod(i, out_buffer_update_rate) == 0)
        
        fprintf(1, '%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', id, button, x_u, y_u, z_u, x, y, z);

        % create output data
        plot_data = out_buffer';
        plot_data_mag = out_buffer_mag';
        
        
        % XYZ
        
        % plot data
        plot(axes_signal, plot_data);
        
        % plot segmentation bar if required
        if (~restPosition)
            hold(axes_signal, 'on');
            start = max(0, gesture_out_start);
            line('Parent', axes_signal, 'LineWidth', 10, 'Color', 'y', 'XData', [start out_buffer_ctr], 'YData', [0 0]);
            hold(axes_signal, 'off');
        elseif (gesture_out_end > 0)
            hold(axes_signal, 'on');
            start = max(0, gesture_out_start);
            line('Parent', axes_signal, 'LineWidth', 10, 'Color', 'y', 'XData', [start gesture_out_end], 'YData', [0 0]);
            hold(axes_signal, 'off');
        end
        
        % plot titles
        title(axes_signal, 'x/y/z signals');
        xlabel(axes_signal, 'time');
        ylabel(axes_signal, 'a [mg]');
        
        
        
        % MAGNITUDE

        % plot data 
        plot(axes_mag, plot_data_mag);
        
        % plot segmentation bar if required
        if (~restPosition)
            hold(axes_mag, 'on');
            start = max(0, gesture_out_start);
            line('Parent', axes_mag, 'LineWidth', 10, 'Color', 'y', 'XData', [start out_buffer_ctr], 'YData', [1000 1000]);
            hold(axes_mag, 'off');
        elseif (gesture_out_end > 0)
            hold(axes_mag, 'on');
            start = max(0, gesture_out_start);
            line('Parent', axes_mag, 'LineWidth', 10, 'Color', 'y', 'XData', [start gesture_out_end], 'YData', [1000 1000]);
            hold(axes_mag, 'off');
        end
        
        % plot titles
        title(axes_mag, 'magnitude');
        xlabel(axes_mag, 'time');
        ylabel(axes_mag, 'a [mg]');
        drawnow;
        

        %plot(plot_data); refreshdata(data_stream, 'caller'); drawnow; %pause(0.1);

    end


  
    % drop first character in buffer
    buffer = shiftLeft(buffer, 1);
    buffer(buffer_len) = fread(sensor, 1, 'int8');
    
    

    %decrement start and end point of bar in output buffer
    gesture_out_start = max(gesture_out_start - 1, 0);
    gesture_out_end = max(gesture_out_end - 1, 0);



    
end


% close sensor
fclose(sensor);


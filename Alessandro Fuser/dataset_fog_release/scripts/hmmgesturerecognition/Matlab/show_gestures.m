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


function varargout = show_gestures()

global gestures;
global gestures_initialized;

% maximum number of training units displayed
global UNITS;

win_width = 1400;
win_height = 900;

space = 0.1; % space (%) between gestures in total
top = 0.02; % space (%) between top row and upper edge of window
info_width = 250; % width (distance) of info boxes

space_vert = 0.3;
start_vert = 0.94;

name_width = 100;
name_height = 15;



buttons = cell(1, 1);
axis_handle = cell(1, 1);
tables = cell(1, 1);


% create LL matrix
columnName = cell(1,1);
columnName{1, 1} = 'x';
columnName{1, 2} = 'y';
columnName{1, 3} = 'z';
columnName{1, 4} = 'mag';
rowName = cell(1, 1);
            
            

if (gestures_initialized)
    
    gui = figure('Name', 'Recorded gestures', 'Position', [0, 40, win_width, win_height]);
    
    len = size(gestures);
    len = len(2);
    
    % determine max. number of units per gesture
    maxi = 0;
    for i = 1:len
        gesture = gestures{1, i};
        units = gesture.Units;
        
        if (units > UNITS)
            units = UNITS;
        end
        
        maxi = max(units, maxi);
        rowName{1, i} = gesture.Name;
    end
    
    space_gestures_per = space / cast(len + 1, 'double');
    gesture_width = (1 - space) * win_width / cast(len, 'double');
    gesture_width_per = gesture_width / cast(win_width, 'double');
    plot_width = (gesture_width - info_width) / cast(win_width, 'double');
    plot_height = (start_vert - space_vert) / maxi;
    space_plots_per = (start_vert - maxi * plot_height ) / cast(maxi + 1, 'double');
        

    h = waitbar(0,'Please wait ...');
    for i = 1:len
        
        
        gesture = gestures{1, i};
        units = gesture.Units;
        
        if (units > UNITS)
            units = UNITS;
        end
        
        plot_left = space_gestures_per * i + gesture_width_per * (i - 1);
        name_left = plot_left * win_width;
        name_bottom = win_height - name_height - top * win_height;
              
        buttons{1, i} = uicontrol(gui, 'Style', 'text', 'String', gesture.Name, 'Position', [name_left name_bottom name_width name_height]);
        log_left = (plot_left + plot_width) * win_width + 10;
        buttons{1, i} = uicontrol(gui, 'Style', 'text', 'String', 'Log-Likelihood', 'Position', [log_left name_bottom name_width name_height]);
        
        
        for k = 1:units
            waitbar(((i-1)*units+k)/(len*units),h);
            plot_bottom = start_vert - k * (plot_height + space_plots_per);
            axis_handle{i, k} = axes('Parent', gui, 'Position', [plot_left, plot_bottom, plot_width, plot_height]);
            
            % plot data
            x = gesture.Discrete_data{k, 1};
            y = gesture.Discrete_data{k, 2};
            z = gesture.Discrete_data{k, 3};
            mag = gesture.Discrete_data{k, 4};
            
            plot_len = size(x);
            plot_len = plot_len(2);
            plot_data = zeros(3, plot_len);
            plot_data(1,:) = x;
            plot_data(2,:) = y;
            plot_data(3,:) = z;
            
            plot(axis_handle{i, k},plot_data');
            
            % create training data object to be evaluated for all classes
            data = cell(4, 1);
            data{1, 1} = gesture.Discrete_data{k, 1};
            data{2, 1} = gesture.Discrete_data{k, 2};
            data{3, 1} = gesture.Discrete_data{k, 3};
            data{4, 1} = gesture.Discrete_data{k, 4};
            

            LL = zeros(len, 4);
            
            
            table_left = (plot_left + plot_width) * win_width + 10;
            table_bottom = plot_bottom * win_height;
            table_width = info_width;
            table_height = plot_height * win_height;
            

            for m = 1:len
                current_gesture = gestures{1, m}
                LL(m, :) = round(current_gesture.evaluate(data));
            end     
            tables{i, k} = uitable(gui, 'Data', LL, 'ColumnName', columnName, 'ColumnWidth',{46},'RowName', rowName,...
                'Position', [table_left, table_bottom, table_width, table_height]);
        end

    end
    close(h);
    
end


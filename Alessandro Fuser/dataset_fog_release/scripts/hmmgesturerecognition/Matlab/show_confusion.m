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


function x = show_confusion()

global gestures_initialized;

if (gestures_initialized)

    global gestures;
    len = size(gestures);
    len = len(2);
    confusion_matrix = zeros(len, len);
    confusion_matrix_mag = zeros(len, len);
    columnName = cell(1, 1);

    h = waitbar(0,'Calculating confusion matrix. Please wait ...');
    for i = 1:len

        gesture = gestures{1, i};
        units = gesture.Units;

        columnName{1, i} = gesture.Name;

        for k = 1:units
            waitbar(((i-1)*units+k)/(len*units),h);
            
            % create training data object to be evaluated for all classes
            data = cell(4, 1);
            data{1, 1} = gesture.Discrete_data{k, 1};
            data{2, 1} = gesture.Discrete_data{k, 2};
            data{3, 1} = gesture.Discrete_data{k, 3};
            data{4, 1} = gesture.Discrete_data{k, 4};

            [winner, winner_mag, LL] = classify(data);
            
            if (winner ~= 0)
                confusion_matrix(i, winner) = confusion_matrix(i, winner) + 1;
            end
            
            if (winner_mag ~= 0)
                confusion_matrix_mag(i, winner_mag) = confusion_matrix_mag(i, winner_mag) + 1;
            end

        end

    end
    close(h);

    win_height = 300;
    win_width = 1000;

    confusion_gui = figure('Name', 'Confusion matrices', 'Position', [0, 40, win_width, win_height]);

    rowName = columnName;

    table_confusion = uitable(confusion_gui,...
        'Data', confusion_matrix,...
        'ColumnName', columnName,...
        'RowName', rowName,...
        'Position', [50 20 400 200]);
    
    static_confusion = uicontrol(confusion_gui, 'Style', 'text', 'String', 'x/y/z signal', ...
    'Position', [50 250 400 20]);

    table_confusion_mag = uitable(confusion_gui,...
        'Data', confusion_matrix_mag,...
        'ColumnName', columnName,...
        'RowName', rowName,...
        'Position', [500 20 400 200]);
    
    static_confusion_mag = uicontrol(confusion_gui, 'Style', 'text', 'String', 'magnitude', ...
    'Position', [500 250 400 20]);

end




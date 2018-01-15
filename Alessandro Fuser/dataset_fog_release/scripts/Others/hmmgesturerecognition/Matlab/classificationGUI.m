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


function x = classificationGUI()

global classification_gui;
global classification_status;
global gestures_initialized;
global axes_classification;
global axes_image;

if (gestures_initialized)
    
    
    classification_gui = figure('Name', 'Classification results', 'Position', [750, 300, 600, 650]);
    set(classification_gui, 'CloseRequestFcn', @close_fcn);
    
    mydata = guidata(classification_gui);
    mydata.gui = classification_gui;
    
    static_status_1 = uicontrol(classification_gui, 'Style', 'text', 'String', 'Status', 'FontSize', 12,...
        'Position', [10 590 150 20]);

    static_status_2 = uicontrol(classification_gui, 'Style', 'text', 'Tag', 'status', 'String', 'rest', 'FontWeight', 'bold', 'FontSize', 12,...
        'Position', [200 590 350 20]);

    static_classification =  uicontrol(classification_gui, 'Style', 'text', 'String', 'Last classification', 'FontSize', 12,...
        'Position', [10, 510 540 20]);

    static_result_mag_1 = uicontrol(classification_gui, 'Style', 'text', 'String', 'Magnitude', 'FontSize', 12,...
        'Position', [10, 470 150 20]);

    static_result_mag_2 = uicontrol(classification_gui, 'Style', 'text', 'Tag', 'result_mag', 'String', '', 'FontWeight', 'bold', 'FontSize', 12,...
        'Position', [200, 470 350 20]);

    static_result_xyz_1 = uicontrol(classification_gui, 'Style', 'text', 'String', 'Majority x/y/z', 'FontSize', 12,...
        'Position', [10, 430 150 20]);

    static_result_xyz_2 = uicontrol(classification_gui, 'Style', 'text', 'Tag', 'result_xyz', 'String', '', 'FontWeight', 'bold', 'FontSize', 12,...
        'Position', [200, 430 350 20]);

    static_LL = uicontrol(classification_gui, 'Style', 'text', 'String', 'LL matrix', 'FontSize', 12,...
        'Position', [10, 390 150 20]);
    
    static_pause = uicontrol(classification_gui, 'Style', 'pushbutton', 'String', 'Pause',...
        'Position', [10 340 150 30]);


    set(static_pause, 'Callback', {@callback_pause});
    mydata.pause = static_pause;
    guidata(classification_gui, mydata);

    
    % create LL matrix
    columnName = cell(1,1);
    columnName{1, 1} = 'x';
    columnName{1, 2} = 'y';
    columnName{1, 3} = 'z';
    columnName{1, 4} = 'mag';
    rowName = cell(1, 1);

    global gestures;
    len = size(gestures);
    len = len(2);

    for i = 1:len
        gesture = gestures{1, i};
        rowName{1, i} = gesture.Name;
    end

    LL = zeros(len, 4);

    rowHeight = 25;

    table_height = (len+1)*rowHeight;
    table_height = 100;
    
    table = uitable(classification_gui, 'Tag', 'LL', 'Data', LL, 'ColumnName', columnName, 'RowName', rowName, 'Position', [200 410 - table_height 350 table_height]);
    
    axes_classification = axes('Parent', classification_gui, 'Position', [0.05 0.05 0.4 0.3]);
    
    axes_image = axes('Parent', classification_gui, 'Position', [0.55 0.05 0.4 0.3]);

end



function varargout = callback_pause(h, eventdata)

mydata = guidata(h);
pause = mydata.pause;

% adjust classification flag accordingly
global CLASSIFICATION;

if (CLASSIFICATION == 1)
    set(pause, 'String', 'Resume');
    CLASSIFICATION = 0;
else
    set(pause, 'String', 'Pause');
    CLASSIFICATION = 1;
end






function varargout = close_fcn(h, eventdata)

global CLASSIFICATION;
CLASSIFICATION = 0;

delete(h);
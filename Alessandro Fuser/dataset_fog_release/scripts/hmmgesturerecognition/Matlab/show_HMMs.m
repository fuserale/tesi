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


function x = show_HMMs(index)


global gestures;
global gestures_initialized;


win_width = 1400;
win_height = 600;

name_width = 100;
name_height = 15;

start_vert = 0.9;

space_hor = 0.1;
space_vert = 0.2;
top = 0.1; % space (%) between top row and upper edge of window

% height of matrices (%)
matrix_height_per = 0.2;
matrix_height = matrix_height_per * win_height;


titles = cell(1, 1);
titles{1, 1} = 'x';
titles{1, 2} = 'y';
titles{1, 3} = 'z';
titles{1, 4} = 'mag';




if (gestures_initialized)
    
    len = 4;
    gesture = gestures{1, index};
    
    title = sprintf('Recovered HMMs for %s', gesture.Name);
    hmm_gui = figure('Name', title, 'Position', [0, 40, win_width, win_height]);
    set(hmm_gui, 'CloseRequestFcn', @close_fcn);

    
    mydata = guihandles(hmm_gui);
    mydata.gui = hmm_gui;
    mydata.Index = index;
    
    
    matrix_width_per = (1 - space_hor) / cast(len, 'double');
    matrix_width = matrix_width_per * win_width;
    
    space_matrix_hor_per = space_hor / cast(len + 1, 'double');
    space_matrix_hor = space_matrix_hor_per * win_width;
    
    space_matrix_vert_per = (start_vert - 3 * matrix_height_per) / cast(len, 'double');
    space_matrix_vert = space_matrix_vert_per * win_height;
    
    
    matrix_trans_bottom = space_matrix_vert;
    matrix_obs_bottom = matrix_trans_bottom + space_matrix_vert + matrix_height;
    matrix_init_bottom = matrix_obs_bottom + space_matrix_vert + matrix_height;
    
    tables = cell(len, 3);
    
    
    button_load = uicontrol(hmm_gui, 'Style', 'pushbutton', 'String', 'Apply changes', 'Position',...
        [space_matrix_hor, (1 - top) * win_height + 10, win_width - 2*space_matrix_hor, 25]);
    set(button_load, 'Callback', {@callback_load});
    
   
    
    for i = 1:len
        
        name_left = space_matrix_hor * i + matrix_width * (i - 1);
        name_bottom = win_height - name_height - top * win_height;
        matrix_left = name_left;
        
        
        rowName = cell(1, 1);
        states = size(gesture.Transition_matrix{1, i});
        states = states(1);
    
        for k = 1:states
            rowName{1, k} = sprintf('State %d', k);
        end
    
    
        colName_trans = rowName;
    
        colName_init = cell(1, 1);
        colName_init{1, 1} = 'p';
    
        colName_obs = cell(1, 1);
        obs = size(gesture.Observation_matrix{1, i});
        obs = obs(2);
    
        for k = 1:obs
            colName_obs{1, k} = sprintf('Obs %d', k);
        end
        
        colEdit_init = true;
        colEdit_trans = true(1, states);
        colEdit_obs = true(1, obs);
        
        buttons{1, i} = uicontrol(hmm_gui, 'Style', 'text', 'String', titles{1, i}, 'Position', [name_left name_bottom name_width name_height]);
        
        tables{i, 1} = uitable(hmm_gui,...
            'Data', gesture.Prior_matrix{1, i},...
            'ColumnName', colName_init,...
            'ColumnWidth',{55},...
            'RowName', rowName,...
            'ColumnEditable', colEdit_init,...
            'CellEditCallback', {@callback_table, i, 1},...
            'Position', [matrix_left, matrix_init_bottom, matrix_width, matrix_height]);
        tables{i, 2} = uitable(hmm_gui,...
            'Data', gesture.Transition_matrix{1, i},...
            'ColumnName', colName_trans,...
            'ColumnWidth',{55},...
            'RowName', rowName,...
            'ColumnEditable', colEdit_trans,...
            'CellEditCallback', {@callback_table, i, 2},...
            'Position', [matrix_left, matrix_trans_bottom, matrix_width, matrix_height]);
        tables{i, 3} = uitable(hmm_gui, 'Data', gesture.Observation_matrix{1, i},...
            'ColumnName', colName_obs,...
            'ColumnWidth',{55},...
            'RowName', rowName,...
            'ColumnEditable', colEdit_obs,...
            'CellEditCallback', {@callback_table, i, 3},...
            'Position', [matrix_left, matrix_obs_bottom, matrix_width, matrix_height]);
            
    end
    
    mydata.tables = tables;
    guidata(hmm_gui, mydata);
    
    global SUSPEND_PLOT;
    SUSPEND_PLOT = 1;
    
    
end


function callback_load(h, eventdata)

mydata = guidata(h);
gui = mydata.gui;

global gestures;
gesture = gestures{1, mydata.Index};
gestures{1, mydata.Index} = gesture.normalize();

close(gui);

global SUSPEND_PLOT;
SUSPEND_PLOT = 0;




function varargout = callback_table(h, eventdata, signal, matrixType)

global gestures;
mydata = guidata(h);
gesture = gestures{1, mydata.Index};

i = eventdata.Indices(1, 1);
k = eventdata.Indices(1, 2);

if (matrixType == 1)
    matrix = gesture.Prior_matrix{1, signal};
    matrix(i, k) = eventdata.NewData;
    gesture = gesture.set_prior_matrix(1, signal, matrix);
    gestures{1, mydata.Index} = gesture;
elseif (matrixType == 2)
    matrix = gesture.Transition_matrix{1, signal};
    matrix(i, k) = eventdata.NewData;
    gesture = gesture.set_trans_matrix(1, signal, matrix);
    gestures{1, mydata.Index} = gesture;
else
    matrix = gesture.Observation_matrix{1, signal};
    matrix(i, k) = eventdata.NewData;
    gesture = gesture.set_obs_matrix(1, signal, matrix);
    gestures{1, mydata.Index} = gesture;
end

fprintf('hello signal:%d matrixType:%d\n', signal, matrixType);



function varargout = close_fcn(h, eventdata)

global gestures;
mydata = guidata(h);
gesture = gestures{1, mydata.Index};
gestures{1, mydata.Index} = gesture.normalize();
    
delete(h);
    

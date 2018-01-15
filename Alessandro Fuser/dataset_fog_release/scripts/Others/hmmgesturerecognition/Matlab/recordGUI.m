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


function varargout = recordGUI(name, units)

% only open GUI if sensor is active!
global ACTIVE_SENSOR;
if (ACTIVE_SENSOR == 0)
    return;
end


% allow only one training window to be open!
% neccessary to keep global variable recorded_gesture consistent!
global RECORD_GUI_COUNT;

if (RECORD_GUI_COUNT == 1)
    return;
else
    RECORD_GUI_COUNT = 1;
end

win_width = 1400;
win_height = 370;
button_width = 80;

space = 0.1; % space between graphs in total
space_btw_plots = space / cast(units + 1, 'double'); % space between plots

gui = figure('Name', name, 'Position', [0, 40, win_width, win_height]);
set(gui, 'CloseRequestFcn', @close_fcn);

myhandles = guihandles(gui);
myhandles.gui = gui;
myhandles.name = name;
myhandles.units = units;
myhandles.space = space;
myhandles.space_btw_plots = space_btw_plots;
myhandles.axes_handle = zeros(1, units);


% cell array storing recorded gesture
myhandles.recorded_data = cell(units, 4);

% cell array storing descretized values of gesture
myhandles.discretized_data = cell(units, 4);


button_train = uicontrol(gui, 'Style', 'pushbutton', 'String', 'Train', 'Position', [40, win_height - 50, (win_width - 80) / 2, 30]);
set(button_train, 'Callback', {@callback_train, win_width, win_height});

button_train_indiv = uicontrol(gui, 'Style', 'pushbutton', 'String', 'Train individually', 'Position', [40 + (win_width - 80) / 2, win_height - 50, (win_width - 80) / 2, 30]);
set(button_train_indiv, 'Callback', {@callback_train_individually});


% define buttons and axes
for i = 1:units
          
    plot_width = (1.0 - space) / cast(units, 'double');
    plot_height = 0.5;
    plot_left = space_btw_plots * cast(i, 'double') + plot_width * cast(i - 1, 'double');
    plot_bottom = 0.2;
    
    myhandles.axes_handle(i) = axes('Parent', gui, 'Position', [plot_left, plot_bottom, plot_width, plot_height]);
    
    xpos = cast(plot_left * win_width, 'int32');
    button_start(i) = uicontrol('Parent', gui, 'Value', i, 'Style', 'pushbutton', 'String','Start',...
        'Position', [xpos, 10, button_width, 20]);
    set(button_start(i), 'Callback', {@callback_start, i});
    
    xpos = xpos + button_width;
    button_clear(i) = uicontrol(gui, 'Value', i, 'Style', 'pushbutton', 'String', 'Clear',...
        'Position', [xpos, 10, button_width, 20]);
    set(button_clear(i), 'Callback', {@callback_clear, i});
      
end

guidata(gui, myhandles);

% make training axes visible globally
global axes_training;
axes_training = myhandles.axes_handle;


% initialize recorded gesture
global recorded_gesture;
recorded_gesture.recorded_data = cell(units, 4);
recorded_gesture.discretized_data = cell(units, 4);





% callback functions

function varargout = callback_start(h, eventdata, index)
    
global TRAINING;
TRAINING = index;
    
   
    
function varargout = callback_clear(h, eventdata, index)

global recorded_gesture;
    
mydata = guidata(h);
diagram = mydata.axes_handle(index);
axes(diagram);
plot(1);

% remove recorded data
for k = 1:4
    recorded_gesture.recorded_data{index,k}=[];
end
    
% load new data
guidata(h, mydata);


    
function varargout = callback_train(h, eventdata, win_width, win_height)
    
global recorded_gesture;
mydata = guidata(h);

% check if recorded gestures available at all
if (size(recorded_gesture.recorded_data) == 0)
    return;
end
    
% check if all training units are available
for i = 1:mydata.units
    if (size(recorded_gesture.recorded_data{i, 1}) == 0)
        return; % training unit is missing
    end
end

waiting = uicontrol(mydata.gui, 'Style', 'text', 'String', 'Training. Please wait ...', 'Position', [40, win_height - 80, win_width - 80, 20]);
drawnow;

global TYPE_HMM;
global STATES;
global IT_SP;
global IT_BW;

gesture = Gesture(mydata.name, recorded_gesture.recorded_data, recorded_gesture.discretized_data, STATES, IT_SP, IT_BW, TYPE_HMM);
gesture = gesture.train();

% add object to global gestures
% append gesture to global array of recorded gestures
global gestures;
global gestures_initialized;

if (gestures_initialized == 0)
    gestures{1, 1} = gesture;
    gestures_initialized = 1;
    obj.Index = 1;
else
    len = size(gestures);
    len = len(2);
    gestures{1, len + 1} = gesture;
end

% here: use close! and not delete, as the counter for open windows has to
% be decreased
close(mydata.gui);
    
% open parameter settings for training
%trainingGUI(mydata.name, recorded_gesture.recorded_data, recorded_gesture.discretized_data);

recorded_gesture.recorded_data = cell(1,1);
recorded_gesture.discretized_data = cell(1,1);




function varargout = callback_train_individually(h, eventdata)
    
global recorded_gesture;
mydata = guidata(h);

% check if recorded gestures available at all
if (size(recorded_gesture.recorded_data) == 0)
    return;
end
    
% check if all training units are available
for i = 1:mydata.units
    if (size(recorded_gesture.recorded_data{i, 1}) == 0)
        return; % training unit is missing
    end
end

delete(mydata.gui);
    
% open parameter settings for training
trainingGUI(mydata.name, recorded_gesture.recorded_data, recorded_gesture.discretized_data);

recorded_gesture.recorded_data = cell(1,1);
recorded_gesture.discretized_data = cell(1,1);




function varargout = close_fcn(h, eventdata)

global RECORD_GUI_COUNT;
RECORD_GUI_COUNT = 0;

global TRAINING;
TRAINING = 0;

global recorded_gesture;
recorded_gesture.recorded_data = cell(1,1);
recorded_gesture.discretized_data = cell(1,1);

delete(h);    

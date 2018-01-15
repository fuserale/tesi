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


function varargout = retrainGUI()


global gestures_initialized;

if (~gestures_initialized)
    return;
end


width = 700;
height = 500;

settings_gui = figure('Name', 'Settings', 'Position', [0 100 width height]);

global window_size
global window_offset;
global ENERGY_TH;
global DISTANCE_TH;

global baseline;
global feature_count;
global int_width;
global feature_count_mag;
global int_width_mag;

global TYPE_HMM;
global STATES;
global IT_SP;
global IT_BW;


mydata = guidata(settings_gui);
mydata.gui = settings_gui;
guidata(settings_gui, mydata);



% DISCRETIZATION

static_discretization = uicontrol(settings_gui, 'Style', 'text', 'String', 'Discretization', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [20 460 300 25]);

static_mag = uicontrol(settings_gui, 'Style', 'text', 'String', 'xyz',...
    'Position', [20 280 90 160]);

static_baseline = uicontrol(settings_gui, 'Style', 'text', 'String', 'magnitude',...
    'Position', [20 160 90 100]);

static_baseline = uicontrol(settings_gui, 'Style', 'text', 'String', 'Baseline for features (R)',...
    'Position', [120 420 200 20]);
dynamic_baseline = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'baseline', 'String', sprintf('%d', baseline), 'Min', 1, 'Max', 0, ...
    'Position', [120 400 200 20]);

static_features = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of features', ...
    'Position', [120 360 200 20]);
dynamic_features = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'feature_count', 'String', sprintf('%d', feature_count), 'Min', 1, 'Max', 0, ...
    'Position', [120 340 200 20]);

static_interval_width = uicontrol(settings_gui, 'Style', 'text', 'String', 'Interval width (dR)',...
    'Position', [120 300 200 20]);
dynamic_interval_width = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'int_width', 'String', sprintf('%d', int_width), 'Min', 1, 'Max', 0, ...
    'Position', [120 280 200 20]);

static_features = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of features', ...
    'Position', [120 240 200 20]);
dynamic_features = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'feature_count_mag', 'String', sprintf('%d', feature_count_mag), 'Min', 1, 'Max', 0, ...
    'Position', [120 220 200 20]);

static_interval_width = uicontrol(settings_gui, 'Style', 'text', 'String', 'Interval width (dR)',...
    'Position', [120 180 200 20]);
dynamic_interval_width = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'int_width_mag', 'String', sprintf('%d', int_width_mag), 'Min', 1, 'Max', 0, ...
    'Position', [120 160 200 20]);


% CLASSIFICATION

static_hmm = uicontrol(settings_gui, 'Style', 'text', 'String', 'HMMs', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [350 460 300 25]);

bgh = uibuttongroup('Parent', settings_gui, 'Title', 'Type of HMM', 'Tag', 'group',...
    'Position', [350 / width, (440 / height) - 0.15, 300 / width, 0.15]);
rbh1 = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', '0', 'String', 'Fully connected', 'Units', 'normalized',...
    'Position', [0.1, 0.7, 0.6, 0.3]);
rbh2 = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', '1', 'String', 'Left-right', 'Units', 'normalized', 'Position',...
    [0.1, 0.2, 0.6, 0.3]);

if (TYPE_HMM == 0)
    set(bgh, 'SelectedObject', rbh1);
else
    set(bgh, 'SelectedObject', rbh2);
end
   

static_states = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of states',...
    'Position', [350 300 300 20]);
dynamic_states = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'states', 'String', sprintf('%d', STATES), 'Min', 1, 'Max', 0, ...
    'Position', [350 280 300 20]);

static_sp_iterations = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of iterations for initial starting point',...
    'Position', [350 240 300 20]);
dynamic_sp_iterations = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'it_sp', 'String', sprintf('%d', IT_SP), 'Min', 1, 'Max', 0, ...
    'Position', [350 220 300 20]);

static_BW_iterations = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of Baum-Welch iterations',...
    'Position', [350 180 300 20]);
dynamic_BW_iterations = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'it_bw', 'String', sprintf('%d', IT_BW), 'Min', 1, 'Max', 0, ...
    'Position', [350 160 300 20]);

check_box = uicontrol(settings_gui, 'Style', 'checkbox', 'String', 'Retrain only magnitude', 'Value', 0, 'Tag', 'cb',...
    'Position', [350 120 300 20]);




% LOAD

button_retrain   = uicontrol(settings_gui, 'Style', 'pushbutton', 'String', 'Retrain', 'Position', [20 40 630 30]);
set(button_retrain, 'Callback', {@callback_retrain});




function varargout = callback_retrain(h, eventdata)


handles = guihandles(h);
mydata = guidata(h);
 
global baseline;
global feature_count;
global int_width;
global feature_count_mag;
global int_width_mag;

global TYPE_HMM;
global STATES;
global IT_SP;
global IT_BW;

global ONLY_MAG;

% DISCRETIZATION
baseline = convert( get(handles.baseline, 'String'), 'uint16' );
baseline = cast(baseline, 'double');
feature_count = convert( get(handles.feature_count, 'String'), 'uint16' );
feature_count = cast(feature_count, 'double');
int_width = convert( get(handles.int_width, 'String'), 'uint16' );
int_width = cast(int_width, 'double');
feature_count_mag = convert( get(handles.feature_count_mag, 'String'), 'uint16' );
feature_count_mag = cast(feature_count_mag, 'double');
int_width_mag = convert( get(handles.int_width_mag, 'String'), 'uint16' );
int_width_mag = cast(int_width_mag, 'double');

% CLASSIFICATION
rb = get(handles.group, 'SelectedObject');
string = get(rb, 'Tag');
type = str2double(string);
TYPE_HMM = cast(type, 'uint8');
STATES = convert( get(handles.states, 'String'), 'uint16' );
IT_SP = convert( get(handles.it_sp, 'String'), 'uint16' );
IT_BW = convert( get(handles.it_bw, 'String'), 'uint16' );

ONLY_MAG = get(handles.cb, 'Value');

% retrain gestures
global gestures;

len = size(gestures);
len = len(2);

new_gestures = cell(1, len);


waiting = uicontrol(mydata.gui, 'Style', 'text', 'String', '',...
        'Position', [20 80 630 20]);


for i = 1:len

    g = gestures{1, i};
    units = g.Units;
    recorded_data = g.Recorded_data;
    discrete_data = cell(units, 4);
    
    for k = 1:units
    
        x = discretize(recorded_data{k, 1}, baseline, feature_count, int_width);
        y = discretize(recorded_data{k, 2}, baseline, feature_count, int_width);
        z = discretize(recorded_data{k, 3}, baseline, feature_count, int_width);
        m = discretizePositive(recorded_data{k, 4}, feature_count_mag, int_width_mag);

        discrete_data{k, 1} = x;
        discrete_data{k, 2} = y;
        discrete_data{k, 3} = z;
        discrete_data{k, 4} = m;
        
    end
    
    % please-wait button
    display = sprintf('Training %s. Please wait ...', g.Name);
    set(waiting, 'String', display);
    drawnow;
    
    new_g = Gesture(g.Name, g.Recorded_data, discrete_data, STATES, IT_SP, IT_BW, TYPE_HMM);
    new_g = new_g.train();
    new_gestures{1, i} = new_g;
    
end

% save retrained gestures
gestures = new_gestures;

mydata = guidata(h);
close(mydata.gui);



   
function x = convert(data, type)

data = str2double(data);
data = cast(data, type);
x = data;

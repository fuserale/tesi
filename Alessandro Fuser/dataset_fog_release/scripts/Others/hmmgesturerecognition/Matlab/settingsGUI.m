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


function varargout = settingsGUI(varargin)


width = 1400;
height = 500;

settings_gui = figure('Name', 'Settings', 'Position', [0 100 width height]);

global sensor_src;
global baud_rate;

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


% SENSOR

static_sensor = uicontrol(settings_gui, 'Style', 'text', 'String', 'Sensor', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [20 460 300 25]);

static_dev = uicontrol(settings_gui, 'Style', 'text', 'String', 'Sensor source device', ...
    'Position', [20 420 300 20]);
dynamic_dev = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'sensor', 'String', sensor_src, 'Min', 1, 'Max', 0, ...
    'Position', [20 400 300 20]);

static_baud = uicontrol(settings_gui, 'Style', 'text', 'String', 'Sensor baud rate', ...
    'Position', [20 360 300 20]);
dynamic_baud = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'baud', 'String', baud_rate, 'Min', 1, 'Max', 0, ...
    'Position', [20 340 300 20]);


% SEGMENTATION

static_segmentation = uicontrol(settings_gui, 'Style', 'text', 'String', 'Segmentation', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [350 460 300 25]);

static_win_size = uicontrol(settings_gui, 'Style', 'text', 'String', 'Sliding window size', ...
    'Position', [350 420 300 20]);
dynamic_win_size = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'win_size', 'String', sprintf('%d', window_size), 'Min', 1, 'Max', 0, ...
    'Position', [350 400 300 20]);

static_win_off = uicontrol(settings_gui, 'Style', 'text', 'String', 'Sliding window offset', ...
    'Position', [350 360 300 20]);
dynamic_win_off = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'win_off', 'String', sprintf('%d', window_offset), 'Min', 1, 'Max', 0, ...
    'Position', [350 340 300 20]);

% group_seg = uibuttongroup('Parent', settings_gui, 'Title', 'Approach', 'Tag', 'seg',...
%     'Position', [350 / width, (320 / height) - 0.15, 300 / width, 0.15]);
% seg1 = uicontrol(group_seg, 'Style', 'radiobutton', 'Tag', '0', 'String', 'Energy-based', 'Units', 'normalized',...
%     'Position', [0.1, 0.7, 0.6, 0.3]);
% seg2 = uicontrol(group_seg, 'Style', 'radiobutton', 'Tag', '1', 'String', 'Distance-based', 'Units', 'normalized', 'Position',...
%     [0.1, 0.2, 0.6, 0.3]);

static_energy = uicontrol(settings_gui, 'Style', 'text', 'String', 'Energy threshold',...
    'Position', [350 300 300 20]);
dynamic_energy = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'energy', 'String', sprintf('%d', ENERGY_TH), 'Min', 1, 'Max', 0, ...
    'Position', [350 280 300 20]);

static_distance = uicontrol(settings_gui, 'Style', 'text', 'String', 'Distance threshold',...
    'Position', [350 240 300 20]);
dynamic_distance = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'distance', 'String', sprintf('%d', DISTANCE_TH), 'Min', 1, 'Max', 0, ...
    'Position', [350 220 300 20]);



% DISCRETIZATION

static_discretization = uicontrol(settings_gui, 'Style', 'text', 'String', 'Discretization', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [680 460 300 25]);

static_mag = uicontrol(settings_gui, 'Style', 'text', 'String', 'xyz',...
    'Position', [680 280 90 160]);

static_baseline = uicontrol(settings_gui, 'Style', 'text', 'String', 'magnitude',...
    'Position', [680 160 90 100]);

static_baseline = uicontrol(settings_gui, 'Style', 'text', 'String', 'Baseline for features (R)',...
    'Position', [780 420 200 20]);
dynamic_baseline = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'baseline', 'String', sprintf('%d', baseline), 'Min', 1, 'Max', 0, ...
    'Position', [780 400 200 20]);

static_features = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of features', ...
    'Position', [780 360 200 20]);
dynamic_features = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'feature_count', 'String', sprintf('%d', feature_count), 'Min', 1, 'Max', 0, ...
    'Position', [780 340 200 20]);

static_interval_width = uicontrol(settings_gui, 'Style', 'text', 'String', 'Interval width (dR)',...
    'Position', [780 300 200 20]);
dynamic_interval_width = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'int_width', 'String', sprintf('%d', int_width), 'Min', 1, 'Max', 0, ...
    'Position', [780 280 200 20]);

static_features = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of features', ...
    'Position', [780 240 200 20]);
dynamic_features = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'feature_count_mag', 'String', sprintf('%d', feature_count_mag), 'Min', 1, 'Max', 0, ...
    'Position', [780 220 200 20]);

static_interval_width = uicontrol(settings_gui, 'Style', 'text', 'String', 'Interval width (dR)',...
    'Position', [780 180 200 20]);
dynamic_interval_width = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'int_width_mag', 'String', sprintf('%d', int_width_mag), 'Min', 1, 'Max', 0, ...
    'Position', [780 160 200 20]);


% CLASSIFICATION

static_hmm = uicontrol(settings_gui, 'Style', 'text', 'String', 'HMMs', 'FontWeight', 'bold', 'FontSize', 12,...
    'Position', [1010 460 300 25]);

bgh = uibuttongroup('Parent', settings_gui, 'Title', 'Type of HMM', 'Tag', 'group',...
    'Position', [1010 / width, (440 / height) - 0.15, 300 / width, 0.15]);
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
    'Position', [1010 300 300 20]);
dynamic_states = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'states', 'String', sprintf('%d', STATES), 'Min', 1, 'Max', 0, ...
    'Position', [1010 280 300 20]);

static_sp_iterations = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of iterations for initial starting point',...
    'Position', [1010 240 300 20]);
dynamic_sp_iterations = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'it_sp', 'String', sprintf('%d', IT_SP), 'Min', 1, 'Max', 0, ...
    'Position', [1010 220 300 20]);

static_BW_iterations = uicontrol(settings_gui, 'Style', 'text', 'String', 'Number of Baum-Welch iterations',...
    'Position', [1010 180 300 20]);
dynamic_BW_iterations = uicontrol(settings_gui, 'Style', 'edit', 'Tag', 'it_bw', 'String', sprintf('%d', IT_BW), 'Min', 1, 'Max', 0, ...
    'Position', [1010 160 300 20]);


% LOAD

button_load   = uicontrol(settings_gui, 'Style', 'pushbutton', 'String', 'OK', 'Position', [20 40 1290 30]);
set(button_load, 'Callback', {@callback_load});



function varargout = callback_load(h, eventdata)

handles = guihandles(h);
 
global sensor_src;
global baud_rate;

global window_size;
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


% SENSOR
sensor_src = get(handles.sensor, 'String');
baud_rate = convert( get(handles.baud, 'String'), 'uint16' );


% SEGMENTATION
% rb = get(handles.seg, 'SelectedObject');
% string = get(rb, 'Tag');
% segmentation_approach = str2double(string);
ENERGY_TH = convert( get(handles.energy, 'String'), 'uint16' );
DISTANCE_TH = convert( get(handles.distance, 'String'), 'uint16' );
window_size = convert( get(handles.win_size, 'String'), 'uint16' );
window_offset = convert( get(handles.win_off, 'String'), 'uint16' );


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


close();


% if (segmentation_approach == 1)
%     restPosGUI();
% else
%     global gesture_rest_position;
%     gesture_rest_position = [-Inf -Inf -Inf];
% end





   
function x = convert(data, type)

data = str2double(data);
data = cast(data, type);
x = data;
        


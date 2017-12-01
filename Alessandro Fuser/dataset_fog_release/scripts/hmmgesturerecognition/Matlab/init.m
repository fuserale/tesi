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


function init()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global rate;

global large_buffer;
global large_buffer_update_rate;
global large_buffer_period;
global large_buffer_ind;
global large_buffer_len;

global out_buffer;
global out_buffer_update_rate;
global out_buffer_period;
global out_buffer_len;
global out_buffer_ctr;
global out_buffer_mag;

global buffer_len;

global discretized_buffer;

global baseline;
global feature_count;
global int_width;
global feature_count_mag;
global int_width_mag;


global gestures;
global gestures_initialized;
global gesture_rest_position;

global TRAINING;
global CLASSIFICATION;
global ENERGY_TH;
global DISTANCE_TH;
global window_size;
global window_offset;

global DATA_DIR;

global RECORD_GUI_COUNT;
global TERMINATE;


global sensor_src;
global baud_rate;

global ACTIVE_SENSOR;

global TYPE_HMM;
global STATES;
global IT_SP;
global IT_BW;

global UNITS;

global ONLY_MAG;


% flag indicating only magnitude signal is to be trained
ONLY_MAG = 0;

% maximum number of training units that can be displayed
UNITS = 10;

% number of open record guis
RECORD_GUI_COUNT = 0;

% directory in which recorded gestures are stored
DATA_DIR = 'data';

% flag indicating index of instance currently being recorded
TRAINING = 0;

% flag indicating whether classification was activated
CLASSIFICATION = 0;

% cell array containing recorded reference gestures
gestures = cell(1,1);

% flag indicating whether gesture array has already been initialized with a
% first gesture
gestures_initialized = 0;




% SENSOR

sensor_src = '/dev/ttyUSB0';
baud_rate = 19200;

%sensor_src = '/dev/rfcomm8';
%baud_rate = 38400;

% flag indicating whether sensor is active
ACTIVE_SENSOR = 0;

% flag indicating desired termination of sensor stream;
TERMINATE = 0;



% SEGMENTATION

% size of sliding window
window_size = 64;

% offset of sliding window
window_offset = 32;

% threshold for energy-based segmentation
ENERGY_TH = 10000;

% threshold for distance-based segmentation
DISTANCE_TH = window_size * 100;

% array with average values in rest position
gesture_rest_position = [-Inf -Inf -Inf];



% DISCRETIZATION

% baseline for feature determination (R)
baseline = 0;

% there are 2 * feature_count intervals for discretization of the input
% signal
feature_count = 5;

% interval width for discretization (except for the first and last one,
% which are infinite)
int_width = 500;

% number of features for magnitude
feature_count_mag = 10;

% interval width for magnitude
int_width_mag = 500;



% CLASSIFICATION

% type of HMM
TYPE_HMM = 1;

% number of HMM states
STATES = 5;

% number of iterations for starting point determination
IT_SP = 4;

% number of Baum-Welch iterations
IT_BW = 10;




% size of sensor buffer
buffer_len = 3;

% update rate, i.e. every rate_th value of the sensor data stream is
% plotted
out_buffer_update_rate = 20;

% duration of the plot in seconds
out_buffer_period = 10;

% frequency of sensor [Hertz]
frequency = 64;

% length of output buffer
out_buffer_len = out_buffer_period * frequency;

% output buffer
out_buffer = zeros(3, out_buffer_len);

% number of elements in output buffer
out_buffer_ctr = out_buffer_len;

% output buffer for magnitude
out_buffer_mag = zeros(1, out_buffer_len);



% update rate of large buffer
large_buffer_update_rate = 1;

% maximum duration of gesture
% i.e. gestures whose recording takes more than <period> seconds will be
% partially lost
large_buffer_period = 60;

% size of large buffer
large_buffer_len = large_buffer_period * frequency;

% large buffer
large_buffer = zeros(4, large_buffer_len);

% current index in large buffer
% large buffer is a round buffer, i.e. once the buffer is full, incoming
% elements overwrite the elements in the buffer from the beginning
large_buffer_ind = 1;


% buffer containing discretized values of all 4 data streams (x, y, z,
% magnitude)
discretized_buffer = zeros(4, large_buffer_len);






function x = determine_buffer_len(period, rate, update_rate)
    x = period * rate / update_rate;


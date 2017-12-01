function varargout = trainingGUI(name, recorded_data, discretized_data)

% PARAMETERGUI Brief description of GUI.
%       Comments displayed at the command line in response 
%       to the help command. 

% (Leave a blank line following the help.)


%  Initialization tasks
param_gui = figure('Name', 'Parameters', 'Position', [1000, 300, 400, 500]);
set(param_gui, 'CloseRequestFcn', @close_fcn);

myhandles = guidata(param_gui);
myhandles.gui = param_gui;
myhandles.name = name;
myhandles.recorded_data = recorded_data;
myhandles.discretized_data = discretized_data;
guidata(param_gui, myhandles);


%  Construct the components

bgh = uibuttongroup('Parent', param_gui, 'Title', 'Type of HMM', 'Tag', 'group',...
    'Position', [0.05, 0.85, 0.7, 0.15]);
rbh1 = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', '0', 'String', 'Fully connected', 'Units', 'normalized',...
    'Position', [0.1, 0.7, 0.6, 0.3]);
rbh2 = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', '1', 'String', 'Left-right', 'Units', 'normalized', 'Position',...
    [0.1, 0.2, 0.6, 0.3]);

global TYPE_HMM;

if (TYPE_HMM == 0)
    set(bgh, 'SelectedObject', rbh1);
else
    set(bgh, 'SelectedObject', rbh2);
end

            
static_states = uicontrol(param_gui, 'Style', 'text', 'String', 'Number of states',...
    'Position', [10 400 300 20]);
dynamic_states = uicontrol(param_gui, 'Style', 'edit', 'Tag', 'states', 'String', '5', 'Min', 1, 'Max', 0, ...
    'Position', [10 380 300 20]);

static_sp_iterations = uicontrol(param_gui, 'Style', 'text', 'String', 'Number of iterations for initial starting point',...
    'Position', [10 340 300 20]);
dynamic_sp_iterations = uicontrol(param_gui, 'Style', 'edit', 'Tag', 'it_sp', 'String', '4', 'Min', 1, 'Max', 0, ...
    'Position', [10 320 300 20]);

static_BW_iterations = uicontrol(param_gui, 'Style', 'text', 'String', 'Number of Baum-Welch iterations',...
    'Position', [10 280 300 20]);
dynamic_BW_iterations = uicontrol(param_gui, 'Style', 'edit', 'Tag', 'it_bw', 'String', '10', 'Min', 1, 'Max', 0, ...
    'Position', [10 260 300 20]);

button_load = uicontrol(param_gui, 'Style', 'pushbutton', 'String', 'Train', 'Position', [10 20 300 30]);
set(button_load, 'Callback', {@callback_load});





% load all user-entered parameters
function varargout = callback_load(h, eventdata)

    fprintf(1, 'LOADING\n');

    handles = guihandles(h);
    mydata = guidata(h);
    
    % please wait button
    waiting = uicontrol(mydata.gui, 'Style', 'text', 'String', 'Training. Please wait ...',...
    'Position', [10 120 300 20]);
    
    drawnow;
    
    states = convert( get(handles.states, 'String'), 'uint16' );
    it_sp = convert( get(handles.it_sp, 'String'), 'uint16' );
    it_bw = convert( get(handles.it_bw, 'String'), 'uint16' );

    rb = get(handles.group, 'SelectedObject');
    string = get(rb, 'Tag');
    type = str2double(string);
    type = cast(type, 'uint8');
    
    mydata = guidata(h);
    recorded_data = mydata.recorded_data;
    discretized_data = mydata.discretized_data;
    name = mydata.name;
    
    gesture = Gesture(name, recorded_data, discretized_data, states, it_sp, it_bw, type);
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
    
    
    close(mydata.gui);
    
    
%    
function varargout = close_fcn(h, eventdata)

global RECORD_GUI_COUNT;
RECORD_GUI_COUNT = 0;

global recorded_gesture;
recorded_gesture.recorded_data = cell(1,1);
recorded_gesture.discretized_data = cell(1,1);

delete(h);       
    
    

% convert data (String) to the desired data type
function x = convert(data, type)

data = str2double(data);
data = cast(data, type);
x = data;
        
           


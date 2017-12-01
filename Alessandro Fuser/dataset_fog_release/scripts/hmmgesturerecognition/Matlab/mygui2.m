function varargout = mygui(varargin)
% MYGUI Brief description of GUI.
%       Comments displayed at the command line in response 
%       to the help command. 

% (Leave a blank line following the help.)


%  Initialization tasks

global main_gui;

main_gui = figure('Name', 'Gesture Classification', 'Position', [0 800 1000 500]);
set(main_gui, 'CloseRequestFcn', @close_fcn);


init();

delta = 30;

%  Construct the components
button_settings         = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Settings', 'Position', [30-delta 110 80 30]);
button_activation       = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Activate', 'Position', [140-delta 110 80 30]);
button_restpos          = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'RestPos', 'Position', [140-delta 70 80 30]);
button_training         = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Add gesture', 'Callback', @callback_gesture, 'Position', [250-delta 110 150 30]);
static_name             = uicontrol(main_gui, 'Style', 'text', 'String', 'name', 'Position', [250-delta 85 75 20]);
static_units            = uicontrol(main_gui, 'Style', 'text', 'String', 'units', 'Position', [250-delta 60 75 20]);
dynamic_name            = uicontrol(main_gui, 'Style', 'edit', 'Tag', 'name', 'String', 'name', 'Min', 1, 'Max', 0, 'Position', [325-delta 85 75 20]);
dynamic_units           = uicontrol(main_gui, 'Style', 'edit', 'Tag', 'units', 'String', '3', 'Min', 1, 'Max', 0, 'Position', [325-delta 60 75 20]);
button_gestures         = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Show gestures', 'Position', [430-delta 110 150 30]);
button_HMMs             = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Show HMMs', 'Position', [430-delta 70 150 30]);
button_confusion        = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Confusion matrix', 'Position', [430-delta 30 150 30]);
button_classification   = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Classify', 'Callback', @callback_classification, 'Position', [610-delta 30 100 30]);


button_load             = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Load gestures', 'Callback', @callback_load, 'Position', [610-delta 110 110 30]);
button_save             = uicontrol(main_gui, 'Style', 'pushbutton', 'String', 'Save gestures', 'Callback', @callback_save, 'Position', [610-delta 70 110 30]);
dynamic_load            = uicontrol(main_gui, 'Style', 'edit', 'Tag', 'load', 'String', 'matlab.mat', 'Min', 1, 'Max', 0, 'Position', [720-delta 110 100 30]);
dynamic_save            = uicontrol(main_gui, 'Style', 'edit', 'Tag', 'save', 'String', 'matlab.mat', 'Min', 1, 'Max', 0, 'Position', [720-delta 70 100 30]);
    
global axes_signal;
axes_signal = axes('Parent', main_gui, 'Position', [0.06 0.4 0.4 0.5]);
set(get(axes_signal, 'Title'), 'String', 'x/y/z signals');
set(get(axes_signal, 'XLabel'), 'String', 'time');
set(get(axes_signal, 'YLabel'), 'String', 'a [mg]');

global axes_mag;
axes_mag = axes('Parent', main_gui, 'Position', [0.56 0.4 0.4 0.5]);
set(get(axes_mag, 'Title'), 'String', 'magnitude');
set(get(axes_mag, 'XLabel'), 'String', 'time');
set(get(axes_mag, 'YLabel'), 'String', 'a [mg]');


%  Initialization tasks


%  Callbacks for MYGUI
set(button_settings, 'Callback', 'settingsGUI');
set(button_activation, 'Callback', 'newStream');
set(button_gestures, 'Callback', 'show_gestures');
set(button_confusion, 'Callback', 'show_confusion');
set(button_HMMs, 'Callback', 'select_HMM');
set(button_restpos, 'Callback', 'restposGUI');


function varargout = callback_gesture(h, eventData)

handles = guihandles;
    
name = get(handles.name, 'String');
units = get(handles.units, 'String');
units = str2double(units);
units = cast(units, 'uint8');
recordGUI(name, units);
    




function varargout = callback_classification(h, eventdata)

global CLASSIFICATION;
CLASSIFICATION = 1;
classificationGUI();
    


function varargout = callback_load(h, eventdata)

global gestures;
global gestures_initialized;
global DATA_DIR;

handles = guihandles(h);
filename = get(handles.load, 'String');
file = sprintf('%s/%s', DATA_DIR, filename);
load(file, 'gestures');

g = gestures{1, 1};
len = size(g);
len = len(1);

if (len ~= 0)
    gestures_initialized = 1;
end



function varargout = callback_save(h, eventdata)

global DATA_DIR;
global gestures;

handles = guihandles(h);
filename = get(handles.save, 'String');
file = sprintf('%s/%s', DATA_DIR, filename);
save(file, 'gestures');



function varargout = close_fcn(h, eventdata)

global TERMINATE;
TERMINATE = 1;

fclose all;

delete(h);

    
    
    
    
    
    
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% OLD
function varargout = callback_gesture_OLD(h, eventData)

    handles = guihandles;
    name = get(handles.name, 'String');
    units = get(handles.units, 'String');
    units = str2double(units);
    units = cast(units, 'uint8');
    fprintf(1, '%s\t%d\n', name, units);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create gui for gesture training dynamically
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    new_gui_file = strcat(name, 'GUI.m');
    new_gui_name = strcat(name, 'GUI');
    new_gui = fopen(new_gui_file, 'w');
   
    
    win_width = 1500;
    button_width = 80;
    
    command = strcat('function varargout = ', new_gui_name, '(varargin)\n');
    fprintf(new_gui, command);
    
    command = strcat('gui = figure(''Name'', ''', name, ''', ''Position'', [100,0,',int2str(win_width),',300]);\n');
    fprintf(new_gui, command);
    
    % create components
    for i=1:units
        
        % plot
        space = 0.1; % space between graphs in total
        space_btw_plots = space / cast(units + 1, 'double');
        
        plot_width = (1.0 - space) / cast(units, 'double')
        plot_height = 0.6;
        plot_left = space_btw_plots * cast(i, 'double') + plot_width * cast(i - 1, 'double')
        plot_bottom = 0.2;
        
        plot_width_s = sprintf('%f', plot_width);
        plot_height_s = sprintf('%f', plot_height);
        plot_left_s = sprintf('%f', plot_left);
        plot_bottom_s = sprintf('%f', plot_bottom);
        
        command = strcat('axes_handle_', int2str(i), ' = axes(''Parent'', gui, ''Position'', [',plot_left_s, ', ', plot_bottom_s, ', ', plot_width_s, ', ', plot_height_s, ']);\n');
        
        fprintf(1, '%s', plot_left_s);
        fprintf(1, '%s', command);
        
        fprintf(new_gui, command);
        
        % start button
        xpos = cast(plot_left * win_width, 'int32');
        
        fprintf(new_gui, command);
              
        % end button
        xpos = xpos + button_width;
        command = strcat('button_end_',int2str(i),' = uicontrol(gui,''Style'',''pushbutton'',''String'',''End'',''Position'', [',int2str(xpos),',10,',int2str(button_width),',20]);\n');
        fprintf(new_gui, command);
        
        % clear button
        xpos = xpos + button_width;
        command = strcat('button_clear_',int2str(i),' = uicontrol(gui,''Style'',''pushbutton'',''String'',''Clear'',''Position'', [',int2str(xpos),',10,',int2str(button_width),',20]);\n');
        fprintf(new_gui, command);
        
    end
    
    % create callback functions
    for i=1:units
        
        % start button
        function_code = '';
        fprintf(new_gui, function_code)
        
        % end button
        function_code = '';
        fprintf(new_gui, function_code)
        
        % clear button
        function_code = '';
        fprintf(new_gui, function_code);
        
    end
    
    fclose(new_gui);
    fopen(new_gui_file, 'r');
   
    % load new gui
    run(new_gui_name);    
    

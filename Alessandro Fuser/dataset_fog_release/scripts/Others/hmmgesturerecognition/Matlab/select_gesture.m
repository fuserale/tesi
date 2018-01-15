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


function x = select_gesture()


global gestures;
global gestures_initialized;



if (gestures_initialized)

    
    len = size(gestures);
    len = len(2);
    
    buttons = cell(1, len);

    select_gui = figure('Name', 'HMM modification', 'Position', [0, 300, 400, len * 50 + 200]);
    
    bgh = uibuttongroup('Parent', select_gui, 'Title', 'Gesture selection', 'Tag', 'group', 'Position', [0.1, 0.2, 0.7, 0.7]);
    
    button_select = uicontrol(select_gui, 'Style', 'pushbutton', 'String', 'Select', 'Position', [10 20 300 30]);
    set(button_select, 'Callback', {@callback_select});
    
    name_space_vert_per = 0.1;

    name_height_per = (1 - name_space_vert_per) / cast(len, 'double');
    name_left_per = 0.1;
    name_width_per = 0.7;
    
    name_space_single = name_space_vert_per / cast(len + 1, 'double');
    
    for i = 1:len
   
        gesture = gestures{1, i};
        tag = sprintf('%d', i);
        
        inv = len - i + 1;
        
        name_bottom_per = inv * name_space_single + (inv - 1) * name_height_per;
    
        buttons{1, i} = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', tag, 'String', gesture.Name, 'Units', 'normalized',...
            'Position', [name_left_per, name_bottom_per, name_width_per, name_height_per]);
        
    end


end


function varargout = callback_select(h, eventdata)

    handles = guihandles(h);
    mydata = guidata(h);
    
    rb = get(handles.group, 'SelectedObject');
    string = get(rb, 'Tag');
    type = str2double(string);
    type = cast(type, 'uint8');
    
    close();
    show_HMMs(type);



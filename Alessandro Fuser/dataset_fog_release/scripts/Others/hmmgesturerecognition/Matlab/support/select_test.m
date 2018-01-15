function x = select_test()


    len = 2;
    
    buttons = cell(1, len);

    select_gui = figure('Name', 'HMM modification', 'Position', [1100, 550, 400, 400]);
    
    bgh = uibuttongroup('Parent', select_gui, 'Title', 'Gesture selection', 'Tag', 'group', 'Position', [0.1, 0.2, 0.7, 0.7]);
    
    button_select = uicontrol(select_gui, 'Style', 'pushbutton', 'String', 'Select', 'Position', [50 20 300 30]);
    set(button_select, 'Callback', {@callback_select});
    
    name_space_vert_per = 0.1;

    name_height_per = (1 - name_space_vert_per) / cast(len, 'double');
    name_left_per = 0.1;
    name_width_per = 0.7;
    
    name_space_single = name_space_vert_per / cast(len + 1, 'double');
    
    
    for i = 1:len
   
        tag = sprintf('name%d', i);
        
        inv = len - i + 1;
        
        name_bottom_per = inv * name_space_single + (inv - 1) * name_height_per;
        
        name_left_per
        name_bottom_per
        name_width_per
        name_height_per
    
        buttons{1, i} = uicontrol(bgh, 'Style', 'radiobutton', 'Tag', tag, 'String', tag, 'Units', 'normalized',...
            'Position', [name_left_per, name_bottom_per, name_width_per, name_height_per]);
        
    end

function varargout = recordGUI(name, units)


global large_buffer_ind;

win_width = 1600;
win_height = 370;
button_width = 80;

space = 0.1; % space between graphs in total
space_btw_plots = space / cast(units + 1, 'double'); % space between plots

gui = figure('Name', name, 'Position', [0, 40, win_width, win_height]);

myhandles = guihandles(gui);
myhandles.gui = gui;
myhandles.name = name;
myhandles.units = units;
myhandles.space = space;
myhandles.space_btw_plots = space_btw_plots;
myhandles.start_time = zeros(1, units);
myhandles.end_time = zeros(1, units);
myhandles.axes_handle = zeros(1, units);


% cell array storing recorded gesture
myhandles.recorded_data = cell(units, 4);

% cell array storing descretized values of gesture
myhandles.discretized_data = cell(units, 4);


button_train = uicontrol(gui, 'Style', 'pushbutton', 'String', 'Train HMM', 'Position', [40, win_height - 50, win_width - 80, 30]);
set(button_train, 'Callback', {@callback_train});


% define buttons and axes
for i = 1:units
          
    plot_width = (1.0 - space) / cast(units, 'double');
    plot_height = 0.6;
    plot_left = space_btw_plots * cast(i, 'double') + plot_width * cast(i - 1, 'double');
    plot_bottom = 0.2;
    
    myhandles.axes_handle(i) = axes('Parent', gui, 'Position', [plot_left, plot_bottom, plot_width, plot_height]);
    
    xpos = cast(plot_left * win_width, 'int32');
    button_start(i) = uicontrol('Parent', gui, 'Value', i, 'Style', 'pushbutton', 'String','Start',...
        'Position', [xpos, 10, button_width, 20]);
    set(button_start(i), 'Callback', {@callback_start, i});
    
    xpos = xpos + button_width;
    button_end(i) = uicontrol(gui, 'Value', i, 'Style', 'pushbutton', 'String', 'End',...
        'Position', [xpos, 10, button_width, 20]);
    set(button_end(i), 'Callback', {@callback_end, i});
    
    xpos = xpos + button_width;
    button_clear(i) = uicontrol(gui, 'Value', i, 'Style', 'pushbutton', 'String', 'Clear',...
        'Position', [xpos, 10, button_width, 20]);
    set(button_clear(i), 'Callback', {@callback_clear, i});
      
end

guidata(gui, myhandles);



% callback functions

function varargout = callback_start(h, eventdata, index)
    
    global large_buffer_ind;
   
    mydata = guidata(h);
    mydata.start_time(1, index) = large_buffer_ind;
    large_buffer_ind
    guidata(h, mydata);
    
    

function varargout = callback_end(h, eventdata, index)
    
    global large_buffer;
    global large_buffer_ind;
    global large_buffer_len;
    global discretized_buffer;
    
    mydata = guidata(h);
    mydata.end_time(1, index) = large_buffer_ind;
    large_buffer_ind
    
    mystart = mydata.start_time(1, index);
    myend = large_buffer_ind;
    
    if (mystart ~= 0)
        
        record_len = mod((myend - 1) - (mystart - 1), large_buffer_len) + 1;
        record = zeros(4, record_len);
        discretized_record = zeros(4, record_len);
        
        % copy data from buffer
        i = mystart - 1;
        ctr = 1;
        
        %fprintf(1, 'start: %d, end: %d\n', mystart, myend);
        
        while (ctr <= record_len)
            
            % get buffer contents
            for k = 1:4
                record(k, ctr) = large_buffer(k, i + 1);
                discretized_record(k, ctr) = discretized_buffer(k, i + 1);
            end
            
            % update indices
            i = mod(i + 1, large_buffer_len);
            ctr = ctr + 1;
            
        end
        
        % save recorded data
        for k = 1:4
            mydata.recorded_data{index, k} = record(k,:);
            mydata.discretized_data{index, k} = discretized_record(k,:);
        end
        
        % plot recorded gesture
        diagram = mydata.axes_handle(index);
        axes(diagram);
        record_plot = record(1:3,:);
        record_plot = record_plot';
        plot(record_plot);
        
        % reset start and end index
        mydata.start_time(1, index) = 0;
        mydata.end_time(1, index) = 0;
        
    else 
        % nothing, as start button has not yet been pressed
    end
    
    guidata(h, mydata);
   
    
    
function varargout = callback_clear(h, eventdata, index)
    
    mydata = guidata(h);
    
    diagram = mydata.axes_handle(index);
    axes(diagram);
    plot(1);
    
    
    % remove recorded data
    for k = 1:4
        mydata.recorded_data{index,k}=[];
    end
    
    % load new data
    guidata(h, mydata);
    
    
function varargout = callback_train(h, eventdata)
    
    mydata = guidata(h);
    
    % check if all training units are available
    for i = 1:mydata.units
        if (size(mydata.recorded_data{i, 1}) == 0)
            return; % training unit is missing
        end
    end
    
    close(mydata.gui);
    
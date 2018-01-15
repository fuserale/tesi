%system('./dx3.sh /dev/ttyUSB0')

buffer_len = 256;

sensor = fopen('/dev/ttyUSB0', 'r');


% load buffer initially
buffer = fscanf(sensor, '%c', buffer_len);

% synchronize initially
i = 0;

while(0)
    
    if (buffer(0) == 'D' && buffer(1) == 'X' && buffer(2) == '3')
        circularshift(buffer, [1,-3]);
        buffer(buffer_len - 3) = fscanf(sensor, '%c', 1);
        buffer(buffer_len - 2) = fscanf(sensor, '%c', 1);
        buffer(buffer_len - 1) = fscanf(sensor, '%c', 1);
    else
        circularshift(buffer, [1,-1]);
        buffer(buffer_len - 1) = fscanf(sensor, '%c', 1);
    end

    i = i + 1;
    
    if (c == 'D')
    end

end




system('stty -F /dev/rfcomm10 38400 raw');

system('stty -F /dev/rfcomm10');

pause(2);


sensor = fopen('/dev/rfcomm10', 'r');

buffer = fread(sensor, 17, 'int8')


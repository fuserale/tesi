clear; clc

A = table2array(readtable('S02R01.csv'));

%choose number of patients to examine (from 1 to 10)
for isubject = [2 3 4 5 6 7 8 9 10]
    
    %list of all files for patient number $isubject
    fileruns = dir(['S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        
        %name of the file
        filename = fileruns(r).name;
        %read table given in input
        T = readtable(filename);
        %take the dimesion
        [m,n] = size(T);
        %table to array to do maths
        B = table2array(T);
        
        A = [A ; B];
        
    end
end
P = array2table(A);
writetable(P, 'leaveout_1.csv');
disp('leaveout_1.csv');
A = [];
clear; clc

A = [];
datadir = '';

for isubject = [2 3 4 5 6 7 8 9 10]
    
    fileruns = dir([datadir 'S' num2str(isubject,'%02d') 'R01.csv']);

    for r = 1:length(fileruns)
        
        filename = fileruns(r).name;
        B = table2array(readtable(filename));
        
        A = [A ; B];
        
    end
end

P = array2table(A);
writetable(P, [datadir '2cl_leaveout_1.csv']);
disp([datadir '2cl_leaveout_1.csv']);
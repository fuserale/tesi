clear; clc

datadir = '../dataset/';

%choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 4 5 6 7 8 9 10]
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir '3cl_S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        
        %name of the file
        filename = [datadir fileruns(r).name];
        %read table given in input
        T = readtable(filename);
        %take the dimesion
        [m,n] = size(T);
        %table to array to do maths
        A = table2array(T);
        number_sample = 1;
        for i=1:2:m-1
           B(number_sample,:) = A(i,:); 
           number_sample = number_sample + 1;
        end
        writetable(array2table(B),[datadir fileruns(r).name]);
        disp([datadir fileruns(r).name]);
    end
end
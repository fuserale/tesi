clear; clc

datadir_dataset = '../../dataset/';

%list of all files for patient number $isubject
fileruns = dir([datadir_dataset '*.csv']);

%while there's file of patient $isubject
for r = 1:length(fileruns)
    
    %name of the file
    filename = [datadir_dataset fileruns(r).name];
    %read table given in input
    T = readtable(filename);
    [m,n] = size(T);
    A = table2array(T(:,:));
    
    for p=1:m
        for o=1:n
            if(isnan(A(p,o)))
                A(p,o) = 0;
            end
        end
    end
    
    P = array2table(A);
    writetable(P, [datadir_dataset fileruns(r).name] );
    display([datadir_dataset fileruns(r).name]);
end
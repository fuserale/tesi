clear; clc

datadir = ['../../rate/'];

%list of all files for patient number $isubject
fileruns = dir([datadir '2cl_rate_*.csv']);

C = [];

%while there's file of patient $isubject
for r = 1:length(fileruns)
    
    %name of the file
    filename = [datadir fileruns(r).name];
    %read table given in input
    T1 = readtable(filename);
    [m1,n1] = size(T1);
    A = table2array(T1);
    
    maxPP = 0;
    maxPN = 0;
    maxNP = 0;
    maxNN = 0;
    diffscore = 0;
    riga = 0;
    colonna = 0;
    B = [];
    score1 = 0;
    sc = 0;
    
    for m = 2
        for n = 1:2:n1-1
            temp = ((A(m,n) + A(m+1,n+1)));
            if temp > diffscore
                maxPP = A(m,n);
                maxPN = A(m,n+1);
                maxNP = A(m+1,n);
                maxNN = A(m+1,n+1);
                riga = m + 1;
                colonna = n;
                score1 = temp;
                sc = score1/((A(m,n) + A(m+1,n+1)) + (A(m+1,n) + A(m,n+1)));
            end
        end
    end
    B = [[maxPP maxPN]; [maxNP maxNN]; [riga colonna]; [score1 sc]];
    C = [C B];
end
T = array2table(C);
T.Properties.VariableNames = {'P_1' 'N_1' 'P_2' 'N_2' 'P_3' 'N_3'};
writetable(T, [datadir '2cl_maxrate.csv']);
disp([datadir '2cl_maxrate.csv']);


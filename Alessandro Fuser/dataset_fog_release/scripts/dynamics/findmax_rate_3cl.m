
clear; clc

datadir = ['../../dataset/CSV/feature/dynamics/rate/'];

%list of all files for patient number $isubject
fileruns = dir([datadir '3cl_rate_*.csv']);

C = [];

%while there's file of patient $isubject
for r = 1:length(fileruns)
    
    %name of the file
    filename = [datadir fileruns(r).name];
    %read table given in input
    T1 = readtable(filename);
    [m1,n1] = size(T1);
    A = table2array(T1);
    
    maxA1 = 0;
    maxA2 = 0;
    maxA3 = 0;
    maxB1 = 0;
    maxB2 = 0;
    maxB3 = 0;
    maxC1 = 0;
    maxC2 = 0;
    maxC3 = 0;
    diffscore = 0;
    riga = 0;
    colonna = 0;
    temp1 = 0;
    B = [];
    
    for m = 1:3:m1-2
        for n = 1:3:n1-2
            temp = ((A(m,n) + A(m+1,n+1) + A(m+2,n+2)) - (A(m+1,n) + A(m+2,n) + A(m,n+1) + A(m+2,n+1) + A(m,n+2) + A(m+1,n+2)));
            if temp > diffscore
                maxA1 = A(m,n);
                maxA2 = A(m+1,n);
                maxA3 = A(m+2,n);
                maxB1 = A(m,n+1);
                maxB2 = A(m+1,n+1);
                maxB3 = A(m+2,n+1);
                maxC1 = A(m,n+2);
                maxC2 = A(m+1,n+2);
                maxC3 = A(m+2,n+2);
                riga = m;
                colonna = n;
                temp1 = (maxA1 + maxB2 + maxC3) / 3;
            end
        end
    end
    B = [[maxA1 maxA2 maxA3]; [maxB1 maxB2 maxB3]; [maxC1 maxC2 maxC3]; [riga colonna temp1];];
    C = [C B];
end
T = array2table(C);
T.Properties.VariableNames = {'A_1' 'B_1' 'C_1' 'A_2' 'B_2' 'C_2' 'A_3' 'B_3' 'C_3' 'A_5' 'B_5' 'C_5'};
%T.Properties.RowNames = {'P' 'N' 'R_C'};
writetable(T, [datadir '3cl_maxrate.csv']);
disp([datadir '3cl_maxrate.csv']);

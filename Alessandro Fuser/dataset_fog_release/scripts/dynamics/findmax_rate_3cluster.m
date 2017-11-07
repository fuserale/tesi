
clear; clc

for isubject = [1 2 3 5]
    datadir = ['../../dataset/CSV/feature/dynamics/rate/'];
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir 'rate_*.csv']);
    
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
    T.Properties.VariableNames = {'CMEANS_A' 'CMEANS_B' 'CMEANS_C' 'CMEANS_1ACC_A' 'CMEANS_1ACC_B' 'CMEANS_1ACC_C' 'KMEANS_CB_A' 'KMEANS_CB_B' 'KMEANS_CB_C' 'KMEANS_CB_A_1ACC' 'KMEANS_CB_B_1ACC' 'KMEANS_CB_C_1ACC' 'KMEANS_CS_A' 'KMEANS_CS_B' 'KMEANS_CS_C' 'KMEANS_CS_A_1ACC' 'KMEANS_CS_B_1ACC' 'KMEANS_CS_C_1ACC' 'KMEANS_CR_A' 'KMEANS_CR_B' 'KMEANS_CR_C' 'KMEANS_CR_A_1ACC' 'KMEANS_CR_B_1ACC' 'KMEANS_CR_C_1ACC' 'KMEANS_SQ_A' 'KMEANS_SQ_B' 'KMEANS_SQ_C' 'KMEANS_SQ_A_1ACC' 'KMEANS_SQ_B_1ACC' 'KMEANS_SQ_C_1ACC' 'NET_A' 'NET_B' 'NET_C' 'NET_A_1ACC' 'NET_B_1ACC' 'NET_C_1ACC'};
    %T.Properties.RowNames = {'P' 'N' 'R_C'};
    writetable(T, [datadir 'maxrate.csv']);
    disp([datadir 'maxrate.csv']);
    
end

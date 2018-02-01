
clear; clc
U = [];
for isubject = [1 2 3 4 5 6 7 8 9 10]
    datadir = ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/rate/'];
    
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
        
        diffscore = -100;
        riga = 0;
        colonna = 0;
        B = [];
        
        % 1 = accuracy, 2 = precision, 3 = recall, 4 = F1score 
%         for i = 1:m1
%             for j = 1:4:n1-3
        for i = 1:4
            for j = 1:4:13
                temp = sum(A(i,j:j+3),2);
                if temp > diffscore
                    TRE = A(i,j:j+3);
                    riga = i/2;
                    colonna = secondi(j);
                    diffscore = temp;
                end
            end
        end
        %         B = [[maxA1 maxA2 maxA3]; [maxB1 maxB2 maxB3]; [maxC1 maxC2 maxC3]; [riga colonna temp1]; [precision_NF precision_F precision_PF]; [recall_NF recall_F recall_PF]];
        B = [TRE; riga colonna 0 0];
        C = [C B];
    end
    T = array2table(C);
    U = [U;T];
    writetable(T, [datadir '3cl_maxrate.csv']);
    disp([datadir '3cl_maxrate.csv']);
    
end
writetable(U, '../RateTotale1.csv');
disp('../RateTotale1.csv');

function second = secondi(j)
    if (j == 1)
        second = 1;
    end
    if (j == 5)
        second = 1.5;
    end
    if (j == 9)
        second = 2;
    end
    if (j == 13)
        second = 2.5;
    end
    if (j == 17)
        second = 3;
    end
    if (j == 21)
        second = 3.5;
    end
    if (j == 25)
        second = 4;
    end
    if (j == 29)
        second = 4.5;
    end
    if (j == 33)
        second = 5;
    end
end

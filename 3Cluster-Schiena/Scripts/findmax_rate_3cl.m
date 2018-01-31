
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
        
        maxA1 = 0;
        maxA2 = 0;
        maxA3 = 0;
        maxB1 = 0;
        maxB2 = 0;
        maxB3 = 0;
        maxC1 = 0;
        maxC2 = 0;
        maxC3 = 0;
        diffscore = -100;
        riga = 0;
        colonna = 0;
        temp1 = 0;
        B = [];
        %
        %         for m = 1:3:m1-2
        %             for n = 1:3:n1-2
        %                 TRE = A(m:m+2,n:n+2);
        %                 temp = ((A(m,n) + A(m+1,n+1) + A(m+2,n+2))/(A(m,n)+A(m,n+1)+A(m,n+2)+A(m+1,n)+A(m+1,n+1)+A(m+1,n+2)+A(m+2,n)+A(m+2,n+1)+A(m+2,n+2)));
        %                 if temp > diffscore
        %                     maxA1 = A(m,n);
        %                     maxA2 = A(m+1,n);
        %                     maxA3 = A(m+2,n);
        %                     maxB1 = A(m,n+1);
        %                     maxB2 = A(m+1,n+1);
        %                     maxB3 = A(m+2,n+1);
        %                     maxC1 = A(m,n+2);
        %                     maxC2 = A(m+1,n+2);
        %                     maxC3 = A(m+2,n+2);
        %                     riga = m;
        %                     colonna = n;
        %                     temp1 = temp;
        %                     diffscore = temp;
        %                     precision_NF = A(m,n)/(A(m,n)+A(m,n+1)+A(m,n+2));
        %                     precision_F = A(m+1,n+1)/(A(m+1,n)+A(m+1,n+1)+A(m+1,n+2));
        %                     precision_PF = A(m+2,n+2)/(A(m+2,n)+A(m+2,n+1)+A(m+2,n+2));
        %                     recall_NF = A(m,n)/(A(m,n)+A(m+1,n)+A(m+2,n));
        %                     recall_F = A(m+1,n+1)/(A(m,n+1)+A(m+1,n+1)+A(m+2,n+1));
        %                     recall_PF = A(m+2,n+2)/(A(m,n+2)+A(m+1,n+2)+A(m+2,n+2));
        %                 end
        %             end
        %         end
        
        % 1 = accuracy, 2 = precision, 7 = recall, 11 = specificity, 16 = F1score 
%         for i = 1:m1
%             for j = 1:5:n1-4
        for i = 1:4
            for j = 1:5:16
                temp = sum(A(i,j:j+4),2);
                if temp > diffscore
                    TRE = A(i,j:j+4);
                    riga = i/2;
                    colonna = secondi(j);
                    diffscore = temp;
                end
            end
        end
        %         B = [[maxA1 maxA2 maxA3]; [maxB1 maxB2 maxB3]; [maxC1 maxC2 maxC3]; [riga colonna temp1]; [precision_NF precision_F precision_PF]; [recall_NF recall_F recall_PF]];
        B = [TRE; riga colonna 0 0 0];
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
    if (j == 6)
        second = 1.5;
    end
    if (j == 11)
        second = 2;
    end
    if (j == 16)
        second = 2.5;
    end
    if (j == 21)
        second = 3;
    end
    if (j == 26)
        second = 3.5;
    end
    if (j == 31)
        second = 4;
    end
    if (j == 36)
        second = 4.5;
    end
    if (j == 41)
        second = 5;
    end
end
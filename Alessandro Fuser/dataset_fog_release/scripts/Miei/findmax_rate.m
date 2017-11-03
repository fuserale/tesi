clear; clc

for isubject = 4:10
    datadir = ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/'];
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir '*.csv']);
    
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
        
        for m = 1:2:m1-1
            for n = 1:2:n1-1
                temp = ((A(m,n) + A(m+1,n+1)) - (A(m+1,n) + A(m,n+1)));
                if temp > diffscore
                    maxPP = A(m,n);
                    maxPN = A(m,n+1);
                    maxNP = A(m+1,n);
                    maxNN = A(m+1,n+1);
                    riga = m;
                    colonna = n;
                end
            end
        end
        B = [[maxPP maxPN]; [maxNP maxNN]; [riga colonna];];
        T = array2table(B);
        writetable(T, [datadir 'rate/rate_' fileruns(r).name]);
        display([datadir 'rate/rate_' fileruns(r).name]);
    end
    
end

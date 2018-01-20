clear; clc

for isubject = [1 2 3 5]
    for q=5:5:45
        if q<10
            datadir = ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
        end
        if q>5
            datadir = ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
        end
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir 'feature_sec*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir fileruns(r).name];
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
            writetable(P, [datadir fileruns(r).name] );
            display([datadir fileruns(r).name]);
        end
    end
end
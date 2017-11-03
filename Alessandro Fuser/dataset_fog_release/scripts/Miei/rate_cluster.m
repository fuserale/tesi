clear; clc

for isubject =4:10
    e = [];
    Q = [];
    for q=5:5:45
        if q<10
            datadir = ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
        end
        if q>5
            datadir = ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
        end
        
        E = [];
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir 'feature_sec*.csv']);
        alg = 'kmeans_sqeuclidean';
        fileruns2 = dir([datadir alg '_*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir fileruns(r).name];
            %read table given in input
            T1 = readtable(filename);
            [m1,n1] = size(T1);
            A1 = table2array(T1(:,158));
            
            %name of the file
            filename2 = [datadir fileruns2(r).name];
            %read table given in input
            T2 = readtable(filename2);
            [m2,n2] = size(T2);
            A2 = table2array(T2(:,1));
            
            %il positivo è l'1 (nofog)
            positive_positive = 0;
            positive_negative = 0;
            negative_positive = 0;
            negative_negative = 0;
            number_positive = 0;
            number_negative = 0;
            
            D = [A2 A1];
            
            for i=1:m1
                if D(i,2) == 1
                    number_positive = number_positive + 1;
                end
                if D(i,2) == 2
                    number_negative = number_negative + 1;
                end
            end
            
            for i=1:m1
                if D(i,1) == D(i,2)
                    if D(i,1) == 1
                        positive_positive = positive_positive + 1;
                    end
                    if D(i,1) == 2
                        negative_negative = negative_negative + 1;
                    end
                end
                if D(i,1) ~= D(i,2)
                    if D(i,1) == 1
                        positive_negative = positive_negative + 1;
                    end
                    if D(i,1) == 2
                        negative_positive = negative_positive + 1;
                    end
                end
            end
            
            %[C,order] = confusionmat(D(:,2),D(:,1));
            
            true_positive = positive_positive / number_positive;
            true_negative = negative_negative / number_negative;
            false_positive = positive_negative / number_negative;
            false_negative = negative_positive / number_positive;
            B = [true_positive false_positive; false_negative true_negative];
            E = [E B];
            
            
        end
        Q = [Q ; e E];
        e = [e [0 0; 0 0]];
        
    end
    P = array2table(Q);
    P.Properties.VariableNames = {'PPNP1s' 'PNNN1s' 'PPNP15s' 'PNNN15s' 'PPNP2s' 'PNNN2s' 'PPNP25s' 'PNNN25s' 'PPNP3s' 'PNNN3s' 'PPNP35s' 'PNNN35s' 'PPNP4s' 'PNNN4s' 'PPNP45s' 'PNNN45s' 'PPNP5s' 'PNNN5s'};
    writetable(P, ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/' alg '.csv'] );
    % P.Properties.VariableNames = {'PPNP1s' 'PNNN1s' 'PPNP15s' 'PNNN15s' 'PPNP2s' 'PNNN2s' 'PPNP25s' 'PNNN25s' 'PPNP3s' 'PNNN3s' 'PPNP35s' 'PNNN35s' 'PPNP4s' 'PNNN4s' 'PPNP45s' 'PNNN45s' 'PPNP5s' 'PNNN5s'};
    % P.Properties.RowNames = {'o5' 'o5z' 'o1' 'o1z' 'o15' 'o15z' 'o2' 'o2z' 'o25' 'o25z' 'o3' 'o3z' 'o35' 'o35z' 'o4' 'o4z' 'o45' 'o45z' 'o5' 'o5z'};
    display(['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/' alg '.csv'] );
end
clear; clc
for isubject =[1 ]
    for p = 1:6
        e = [];
        Q = [];
        for q=5:5:45
            if q<10
                datadir = ['../interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
            end
            if q>5
                datadir = ['../interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
            end
            
            E = [];
            
            %list of all files for patient number $isubject
            fileruns = dir([datadir '2cl_feature_sec*.csv']);
            if p == 1
                alg = 'kmeans_cosine';
            end
            if p == 2
                alg = 'kmeans_correlation';
            end
            if p == 3
                alg = 'kmeans_cityblock';
            end
            if p == 4
                alg = 'kmeans_sqeuclidean';
            end
            if p == 5
                alg = 'net';
            end
            if p == 6
                alg = 'cmeans';
            end
            fileruns2 = dir([datadir 'versus_' alg '_2cl_*.csv']);
            
            %while there's file of patient $isubject
            for r = 1:length(fileruns)
                
                %name of the file
                filename = [datadir fileruns(r).name];
                %read table given in input
                T1 = readtable(filename);
                [m1,n1] = size(T1);
                A1 = table2array(T1(:,n1));
                
                %name of the file
                filename2 = [datadir fileruns2(r).name];
                %read table given in input
                T2 = readtable(filename2);
                [m2,n2] = size(T2);
                A2 = table2array(T2(:,2));
                D = [A2 A1];
                
                [C,order] = confusionmat(D(:,2),D(:,1));
                accuracy = c_accuracy(C);
                precision = c_precision(C);
                recall = c_recall(C);
                F1measure = c_F1measure(precision,recall);
                                
                B = [accuracy precision recall F1measure];
                E = [E B];
                
            end
            Q = [Q ; [e E]];
            e = [e [0 0 0 0]];
            
        end
        P = array2table(Q);
%         P.Properties.VariableNames = {'PPNP1s' 'PNNN1s' 'PPNP15s' 'PNNN15s' 'PPNP2s' 'PNNN2s' 'PPNP25s' 'PNNN25s' 'PPNP3s' 'PNNN3s' 'PPNP35s' 'PNNN35s' 'PPNP4s' 'PNNN4s' 'PPNP45s' 'PNNN45s' 'PPNP5s' 'PNNN5s'};
        writetable(P, ['../interval_2cl/S' num2str(isubject,'%02d') 'R01/rate/2cl_rate_' alg '.csv'] );
        % P.Properties.VariableNames = {'PPNP1s' 'PNNN1s' 'PPNP15s' 'PNNN15s' 'PPNP2s' 'PNNN2s' 'PPNP25s' 'PNNN25s' 'PPNP3s' 'PNNN3s' 'PPNP35s' 'PNNN35s' 'PPNP4s' 'PNNN4s' 'PPNP45s' 'PNNN45s' 'PPNP5s' 'PNNN5s'};
        % P.Properties.RowNames = {'o5' 'o5z' 'o1' 'o1z' 'o15' 'o15z' 'o2' 'o2z' 'o25' 'o25z' 'o3' 'o3z' 'o35' 'o35z' 'o4' 'o4z' 'o45' 'o45z' 'o5' 'o5z'};
        disp(['../interval_2cl/S' num2str(isubject,'%02d') 'R01/rate/2cl_rate_' alg '.csv'] );
    end
end

function accuracy = c_accuracy(C)
    giusti = sum(diag(C));
    totale = sum(sum(C));
    accuracy = giusti/totale;
    if isnan(accuracy)
        accuracy = 0;
    end
end

function precision = c_precision(C)
    precision1 = C(1,1)/(C(1,1)+C(2,1));
    precision2 = C(2,2)/(C(1,2)+C(2,2));
    precision = mean([precision1;precision2]);
    if isnan(precision)
        precision = 0;
    end
end

function recall = c_recall(C)
    recall1 = C(1,1)/(C(1,1)+C(1,2));
    recall2 = C(2,2)/(C(2,1)+C(2,2));
    recall = mean([recall1;recall2]);
    if isnan(recall)
        recall = 0;
    end
end

function F1measure = c_F1measure(precision,recall)
    F1measure = 2*precision*recall/(precision+recall);
    if isnan(F1measure)
        F1measure = 0;
    end
end
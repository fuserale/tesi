clear; clc

for isubject = [1 2 3]
    E = [];
    D = [];
    C = [];
    A1 = [];
    for p = 1:6
        datadir = ['../../'];
        datadir2 = ['../../clustering/'];
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir 'dataset/2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
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
        fileruns2 = dir([datadir2 alg '_2cl_dynamics_3cl_S' num2str(isubject,'%02d') '*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir 'dataset/' fileruns(r).name];
            %read table given in input
            T1 = readtable(filename);
            [m1,n1] = size(T1);
            A1 = table2array(T1(:,131));
            
            %name of the file
            filename2 = [datadir2 fileruns2(r).name];
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
            
            [Z,order] = confusionmat(D(:,2),D(:,1));
            
            true_positive = positive_positive / number_positive;
            true_negative = negative_negative / number_negative;
            false_positive = positive_negative / number_negative;
            false_negative = negative_positive / number_positive;
            B = [true_positive false_positive; false_negative true_negative];
            E = [E Z];
            C = [C A2];
        end
    end
    C = [C A1];
    P = array2table(C);
    P.Properties.VariableNames = {'kidx_cos' 'kidx_corr' 'kidx_city' 'kidx_sq' 'nidx' 'cidx' 'idx'};
    writetable(P, [datadir 'rate/2cl_versus_S' num2str(isubject,'%02d') '.csv']);
    P = array2table(E);
    P.Properties.VariableNames = {'PPNP_cos' 'PNNN_cos' 'PPNP_corr' 'PNNN_corr' 'PPNP_city' 'PNNN_city' 'PPNP_sq' 'PNNN_sq' 'PPNP_net' 'PNNN_net' 'PPNP_cme' 'PNNN_cme'};
    writetable(P, [datadir '/rate/2cl_rate_S' num2str(isubject,'%02d') '.csv']);
    display(['../../dataset/CSV/feature/dynamics/rate/2cl_rate_S' num2str(isubject,'%02d') '.csv']);
end
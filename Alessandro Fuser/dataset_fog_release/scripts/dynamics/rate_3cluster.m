clear; clc
for isubject = [1 2 3 5]
    E = [];
    D = [];
    for p = 1:6
        
        datadir = ['../../dataset/CSV/feature/dynamics/'];
        datadir2 = ['../../dataset/CSV/feature/dynamics/clustering/'];
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir 'dynamics_S' num2str(isubject,'%02d') '*.csv']);
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
        fileruns2 = dir([datadir2 alg '_dynamics_S' num2str(isubject,'%02d') '*.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir fileruns(r).name];
            %read table given in input
            T1 = readtable(filename);
            [m1,n1] = size(T1);
            A1 = table2array(T1(:,140));
            
            %name of the file
            filename2 = [datadir2 fileruns2(r).name];
            %read table given in input
            T2 = readtable(filename2);
            [m2,n2] = size(T2);
            A2 = table2array(T2(:,1));
            
            %il positivo è l'1 (nofog)
            A_1 = 0;
            A_2 = 0;
            A_3 = 0;
            B_1 = 0;
            B_2 = 0;
            B_3 = 0;
            C_1 = 0;
            C_2 = 0;
            C_3 = 0;
            number_1 = 0;
            number_2 = 0;
            number_3 = 0;
            
            D = [A2 A1];
            
            for i=1:m1
                if D(i,2) == 1
                    number_1 = number_1 + 1;
                end
                if D(i,2) == 2
                    number_2 = number_2 + 1;
                end
                if D(i,2) == 3
                    number_3 = number_3 + 1;
                end
            end
            
            for i=1:m1
                if D(i,1) == D(i,2)
                    if D(i,1) == 1
                        A_1 = A_1 + 1;
                    end
                    if D(i,1) == 2
                        B_2 = B_2 + 1;
                    end
                    if D(i,1) == 3
                        C_3 = C_3 + 1;
                    end
                end
                if D(i,1) ~= D(i,2)
                    if (D(i,1) == 1 && D(i,2) == 2)
                        A_2 = A_2 + 1;
                    end
                    if (D(i,1) == 1 && D(i,2) == 3)
                        A_3 = A_3 + 1;
                    end
                    if (D(i,1) == 2 && D(i,2) == 1)
                        B_1 = B_1 + 1;
                    end
                    if (D(i,1) == 2 && D(i,2) == 3)
                        B_3 = B_3 + 1;
                    end
                    if (D(i,1) == 3 && D(i,2) == 1)
                        C_1 = C_1 + 1;
                    end
                    if (D(i,1) == 3 && D(i,2) == 2)
                        C_2 = C_2 + 1;
                    end
                end
            end
            
            %[C,order] = confusionmat(D(:,2),D(:,1));
            
            true_A = A_1 / number_1;
            true_B = B_2 / number_2;
            true_C = C_3 / number_3;
            false_A2 = A_2 / number_2;
            false_A3 = A_3 / number_3;
            false_B1 = B_1 / number_1;
            false_B3 = B_3 / number_3;
            false_C1 = C_1 / number_1;
            false_C2 = C_2 / number_2;
            
            B = [true_A false_A2 false_A3; false_B1 true_B false_B3; false_C1 false_C2 true_C];
            E = [E B];
        end
        
        
    end
    P = array2table(E);
    P.Properties.VariableNames = {'cos_A' 'cos_B' 'cos_C' 'corr_A' 'corr_B' 'corr_C' 'city_A' 'city_B' 'city_C' 'sq_A' 'sq_B' 'sq_C' 'net_A' 'net_B' 'net_C' 'cme_A' 'cme_B' 'cme_C'};
    %P.Properties.RowNames = {'o_5_1' 'o_5_2' 'o_5_3' 'o_10_1' 'o_10_2' 'o_10_3' 'o_15_1' 'o_15_2' 'o_15_3' 'o_20_1' 'o_20_2' 'o_20_3' 'o_25_1' 'o_25_2' 'o_25_3'};
    writetable(P, ['../../dataset/CSV/feature/dynamics/rate/rate_S' num2str(isubject,'%02d') '.csv']);
    display(['../../dataset/CSV/feature/dynamics/rate/rate_S' num2str(isubject,'%02d') '.csv']);
    
end
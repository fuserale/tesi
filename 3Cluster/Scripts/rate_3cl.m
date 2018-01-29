clear; clc

for isubject =[1 2 3 4 8]
    for p = 1:6
        e = [];
        Q = [];
        for q=5:5:45
            if q<10
                datadir = ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%01d') '/'];
            end
            if q>5
                datadir = ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(q,'%02d') '/'];
            end
            
            E = [];
            
            %list of all files for patient number $isubject
            fileruns = dir([datadir '3cl_feature_sec*.csv']);
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
            fileruns2 = dir([datadir 'versus_' alg '_3cl_feature*.csv']);
            
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
                
                %                 %il positivo è l'1 (nofog)
                %                 A_1 = 0;
                %                 A_2 = 0;
                %                 A_3 = 0;
                %                 B_1 = 0;
                %                 B_2 = 0;
                %                 B_3 = 0;
                %                 C_1 = 0;
                %                 C_2 = 0;
                %                 C_3 = 0;
                %                 number_1 = 0;
                %                 number_2 = 0;
                %                 number_3 = 0;
                %
                
                %
                %                 for i=1:m1
                %                     if D(i,2) == 1
                %                         number_1 = number_1 + 1;
                %                     end
                %                     if D(i,2) == 2
                %                         number_2 = number_2 + 1;
                %                     end
                %                     if D(i,2) == 3
                %                         number_3 = number_3 + 1;
                %                     end
                %                 end
                %
                %                 for i=1:m1
                %                     if D(i,1) == D(i,2)
                %                         if D(i,1) == 1
                %                             A_1 = A_1 + 1;
                %                         end
                %                         if D(i,1) == 2
                %                             B_2 = B_2 + 1;
                %                         end
                %                         if D(i,1) == 3
                %                             C_3 = C_3 + 1;
                %                         end
                %                     end
                %                     if D(i,1) ~= D(i,2)
                %                         if (D(i,1) == 1 && D(i,2) == 2)
                %                             A_2 = A_2 + 1;
                %                         end
                %                         if (D(i,1) == 1 && D(i,2) == 3)
                %                             A_3 = A_3 + 1;
                %                         end
                %                         if (D(i,1) == 2 && D(i,2) == 1)
                %                             B_1 = B_1 + 1;
                %                         end
                %                         if (D(i,1) == 2 && D(i,2) == 3)
                %                             B_3 = B_3 + 1;
                %                         end
                %                         if (D(i,1) == 3 && D(i,2) == 1)
                %                             C_1 = C_1 + 1;
                %                         end
                %                         if (D(i,1) == 3 && D(i,2) == 2)
                %                             C_2 = C_2 + 1;
                %                         end
                %                     end
                %                 end
                
                %[C,order] = confusionmat(D(:,2),D(:,1));
                % 1 = accuracy, 2 = precision, 7 = recall, 11 = specificity, 16 = F1score
                
                %                 true_A = A_1 / number_1;
                %                 true_B = B_2 / number_2;
                %                 true_C = C_3 / number_3;
                %                 false_A2 = A_2 / number_2;
                %                 false_A3 = A_3 / number_3;
                %                 false_B1 = B_1 / number_1;
                %                 false_B3 = B_3 / number_3;
                %                 false_C1 = C_1 / number_1;
                %                 false_C2 = C_2 / number_2;
                %
                %                 B = [true_A false_A2 false_A3; false_B1 true_B false_B3; false_C1 false_C2 true_C];
                [C,T,D,M,N]=multic(D(:,2),D(:,1));
                B = [D(1) D(2) D(7) D(11) D(16)];
                E = [E B];
                
            end
            Q = [Q ; [e E]];
            %             e = [e [0 0 0; 0 0 0; 0 0 0]];
            e = [e [0 0 0 0 0]];
            
        end
        P = array2table(Q);
        %         P.Properties.VariableNames = {'A_10' 'B_10' 'C_10' 'A_15' 'B_15' 'C_15' 'A_20' 'B_20' 'C_20' 'A_25' 'B_25' 'C_25' 'A_30' 'B_30' 'C_30' 'A_35' 'B_35' 'C_35' 'A_40' 'B_40' 'C_40' 'A_45' 'B_45' 'C_45' 'A_50' 'B_50' 'C_50'};
        %P.Properties.RowNames = {'o_5_1' 'o_5_2' 'o_5_3' 'o_10_1' 'o_10_2' 'o_10_3' 'o_15_1' 'o_15_2' 'o_15_3' 'o_20_1' 'o_20_2' 'o_20_3' 'o_25_1' 'o_25_2' 'o_25_3'};
        writetable(P, ['../interval_3cl/S' num2str(isubject,'%02d') 'R01/rate/3cl_rate_' alg '.csv'] );
        disp(['../interval_3cl/S' num2str(isubject,'%02d') 'R01/rate/3cl_rate_' alg '.csv'] );
    end
end
clc; clear
tic
datadir_patient = 'dataset_3cl/';
datadir = 'dataset_3cl/matrix/';
datadir_versus = 'dataset_3cl/versus/';
datadir_rate = 'dataset_3cl/rate/';
best = 0;
rng(1)
% combinazioni --> 1.5,0.5; 2,0.5; 1.5,1; 2,1;
for windows = 1.5:0.5:2
    for overlap = 0.5:0.5:1
        E = [];
        for isubject = [1 2 3 5 6 7 8 9]
            fileruns = dir([datadir 'matrix_leaveout_S' num2str(isubject,'%02d') '_second' num2str(windows,'%.1f') '_overlap' num2str(overlap,'%.1f') '.csv']);
            filename = [datadir fileruns(1).name];
            T = readtable(filename);
            T = table2array(T);
            feature = T(:,1:2);
            classi = T(:,3);
            
            Mdl = fitcknn(feature,classi,'NumNeighbors',5,'Standardize',1);
            
            idx = kmeans(feature,3,'MaxIter',10000,'Start','cluster','Replicates',5);
            versus = [idx classi];
            writetable(array2table(versus), [datadir_versus 'versus_S' num2str(isubject,'%02d') '_Sec' num2str(windows,'%.01f') '_Ov' num2str(overlap,'%.01f') 'R01.csv']);
            
            [C,~] = confusionmat(idx,classi);
            accuracy = c_accuracy(C);
            precision = c_precision(C);
            recall = c_recall(C);
            F1measure = c_F1measure(precision,recall);
            
            B = [accuracy precision recall F1measure];
            E = [E;B];
        end
        writetable(array2table(E), [datadir_rate 'rate_second' num2str(windows,'%.1f') '_overlap' num2str(overlap,'%.1f') '.csv']);
        temp_best = mean(mean(E));
        if temp_best > best
            best = temp_best;
            best_windows = windows;
            best_overlap = overlap;
        end
    end
end
toc;

for isubject = [1 2 3 5 6 7 8 9]
    fileruns = dir([datadir_patient 'S' num2str(isubject,'%02d') 'R01.csv']);
    filename = [datadir_patient fileruns(1).name];
    T = readtable(filename);
    T = table2array(T);
    [m,n] = size(T);
    A = T(:,1:n-1);
    FREEZE = T(:,n);
    Fs = 64;
    
    size_windows_sec = best_windows;
    size_windows_sample = Fs * size_windows_sec;
    
    size_overlap_sec = best_overlap;
    size_overlap_samples = Fs * overlap;
    
    number_sample = 1;
    clear F classi
    
    for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
        B = A(i:i+size_windows_sample-1,:);
        B=B(:);
        F(number_sample,:)=B';
        classi(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
        number_sample = number_sample + 1;
    end
    ALL = [F classi'];
    idx = kmeans(F,3,'MaxIter',10000,'Start','cluster','Replicates',5);
    Mdl2 = fitcknn(F,idx,'NumNeighbors',5,'Standardize',1);
    
    [C,~] = confusionmat(idx,classi);
    accuracy = c_accuracy(C);
    precision = c_precision(C);
    recall = c_recall(C);
    F1measure = c_F1measure(precision,recall);
    
    B = [accuracy precision recall F1measure]
    
%     [label,score,cost] = predict(Mdl,F);
    
%     [label,score,cost] = predict(Mdl2,F);
%     
%     [C,~] = confusionmat(label,classi);
%     accuracy = c_accuracy(C);
%     precision = c_precision(C);
%     recall = c_recall(C);
%     F1measure = c_F1measure(precision,recall);
%     
%     B = [accuracy precision recall F1measure]
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
precision1 = C(1,1)/(C(1,1)+C(2,1)+C(3,1));
precision2 = C(2,2)/(C(1,2)+C(2,2)+C(3,2));
precision3 = C(3,3)/(C(1,3)+C(2,3)+C(3,3));
precision = mean([precision1;precision2;precision3]);
if isnan(precision)
    precision = 0;
end
end

function recall = c_recall(C)
recall1 = C(1,1)/(C(1,1)+C(1,2)+C(1,3));
recall2 = C(2,2)/(C(2,1)+C(2,2)+C(2,3));
recall3 = C(3,3)/(C(3,1)+C(3,2)+C(3,3));
recall = mean([recall1;recall2;recall3]);
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
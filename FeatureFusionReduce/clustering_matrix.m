%% Inizializzazione
clc; clear
tic
datadir_patient = 'dataset_3cl/';
datadir_matrix = 'dataset_3cl/matrix/';
datadir_versus = 'dataset_3cl/versus/';
datadir_rate = 'dataset_3cl/rate/';
best = 0;
rng(1)
% combinazioni --> 1.5,0.5; 2,0.5; 1.5,1; 2,1;
%% Trovo la finestra e l'overlap migliori
for windows = 1.5:0.5:2
    for overlap = 0.5:0.5:1
        E = [];
        for isubject = [1 2 3 5 6 7 8 9]
            fileruns = dir([datadir_matrix 'matrix_leaveout_S' num2str(isubject,'%02d') '_second' num2str(windows,'%.1f') '_overlap' num2str(overlap,'%.1f') '.csv']);
            filename = [datadir_matrix fileruns(1).name];
            T = readtable(filename);
            T = table2array(T);
            feature = T(:,1:2);
            classi = T(:,3);

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
            best_feature = feature;
            best_classi = classi;
            best_C = C;
        end
    end
end
%% Trovo il migliore k per knn sul leaveout
classError_tmp=1;
for i=1:100
    Mdl_LDA = fitcknn(best_feature,best_classi,'NumNeighbors',i,'Standardize',1);
    CVKNNMdl = crossval(Mdl_LDA);
    classError = kfoldLoss(CVKNNMdl);
    if classError_tmp > classError
        k=i;
        classError_tmp = classError;
    end
end
%% Alleno il knn con il numero di vicini migliore trovato
Mdl_LDA = fitcknn(best_feature,best_classi,'NumNeighbors',k,'Standardize',1);
CVKNNMdl = crossval(Mdl_LDA);
classError = kfoldLoss(CVKNNMdl)
clear classError_tmp;
toc;

for isubject = [1 2 3 5 6 7]
    %% Carico i dati del paziente escluso
    fileruns = dir([datadir_patient 'S' num2str(isubject,'%02d') 'R01.csv']);
    filename = [datadir_patient fileruns(1).name];
    T = readtable(filename);
    T = table2array(T);
    [m,n] = size(T);
    A = T(:,2:n-1);
    FREEZE = T(:,n);
    Fs = 64;
    %% Carico la matrice di trasformazione del leaveout
    fileruns2 = dir([datadir_matrix 'W_S' num2str(isubject,'%02d') '_second' num2str(best_windows,'%.01f') '_overlap' num2str(best_overlap,'%.01f') '.csv']);
    filename2 = [datadir_matrix fileruns2(1).name];
    W1 = readtable(filename2);
    W1 = table2array(W1);
    %% Vettorizzo il paziente escluso
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
    %% Faccio cluster sul paziente escluso e poi LDA sui dati del cluster per allenare il secondo knn
    ALL = [F classi'];
    idx = kmeans(F,3,'MaxIter',10000,'Start','cluster','Replicates',5);
    
    [C1,~] = confusionmat(idx,classi);
    accuracy_1 = c_accuracy(C1);
    precision_1 = c_precision(C1);
    recall_1 = c_recall(C1);
    F1measure_1 = c_F1measure(precision_1,recall_1); 
    rate_cluster = [accuracy_1 precision_1 recall_1 F1measure_1]
    
    A=F';
    [d,N] = size(A);
    
    K =  max(idx);
    
    % 1. Divido le feature tramite le classi Ck
    for k = 1:K
        a = find (idx == k);
        Ck{k} = A(:, a);
    end
    
    % 2. Calcolo la media per ogni classe per ogni finestra
    for k = 1:K
        mk{k} = mean(Ck{k},2);
    end
    % 3. Determino la grandezza di ogni classe
    for k = 1:K
        [d, Nk(k)] = size(Ck{k});
    end
    % 4. determino le within class covariance
    for k = 1:K
        S{k} = 0;
        for i = 1:Nk(k)
            S{k} = S{k} + (Ck{k}(:,i)-mk{k})*(Ck{k}(:,i)-mk{k})';
        end
        S{k} = S{k}./Nk(k);
    end
    Swx = 0;
    for k = 1:K
        Swx = Swx + S{k};
    end
    
    % 5. determino la between class covariance
    % 5.1 determino la media totale
    m = mean(A,2);
    Sbx = 0;
    for k=1:K
        Sbx = Sbx + Nk(k)*((mk{k} - m)*(mk{k} - m)');
    end
    Sbx = Sbx/K;
    
    MA = inv(Swx)*Sbx;
    
    % eigenvalues/eigenvectors
    [V,D] = eig(MA);
    
    % 5: transform matrix
    if (k > 1)
        W = V(:,1:K-1);
    end
    if (k == 1)
        W = V(:,1:1);
    end
    
    % 6: transformation
    Y = W'*A;
    
    Mdl_cluster = fitcknn(Y',idx,'NumNeighbors',k,'Standardize',1);
    CVKNNMdl_cluster = crossval(Mdl_cluster);
    classError_cluster = kfoldLoss(CVKNNMdl_cluster)

    %% Carico il secondo file del paziente escluso
    fileruns3 = dir([datadir_patient 'S' num2str(isubject,'%02d') 'R02.csv']);
    filename3 = [datadir_patient fileruns3(1).name];
    T3 = readtable(filename3);
    T3 = table2array(T3);
    [m,n] = size(T3);
    A3 = T3(:,2:n-1);
    FREEZE3 = T3(:,n);
    Fs = 64;
    number_sample = 1;
    
    for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
        B3 = A3(i:i+size_windows_sample-1,:);
        B3=B3(:);
        F3(number_sample,:)=B3';
        classi3(number_sample)=mode(FREEZE3(i:i+size_windows_sample-1,:));
        number_sample = number_sample + 1;
    end
    %% Testo il knn del cluster sul secondo file del paziente
    Y3 = W'*F3';
    [label,~,~] = predict(Mdl_cluster,Y3');
    classification3 = [classi3' label];
    [C2,~] = confusionmat(classi3',label);
    accuracy_2 = c_accuracy(C2);
    precision_2 = c_precision(C2);
    recall_2 = c_recall(C2);
    F1measure_2 = c_F1measure(precision_2,recall_2);
    rate_knn_cluster = [accuracy_2 precision_2 recall_2 F1measure_2]
    %% Trasformo i dati del paziente escluso usando la W del leaveout
    Y1 = W1'*F3';
    [label,~,~] = predict(Mdl_LDA,Y1');
    [C3,~] = confusionmat(classi3',label);
    accuracy_3 = c_accuracy(C3);
    precision_3 = c_precision(C3);
    recall_3 = c_recall(C3);
    F1measure_3 = c_F1measure(precision_3,recall_3);
    rate_knn_LDA = [accuracy_3 precision_3 recall_3 F1measure_3]
deend

%% Funzioni per la matrice di confusione 3x3
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
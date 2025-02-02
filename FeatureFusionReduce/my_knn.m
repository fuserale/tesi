%% Inizializzazione
clc; clear
tic
datadir_patient = 'dataset_3cl/';
datadir_matrix = 'dataset_3cl/matrix/';
datadir_versus = 'dataset_3cl/versus/';
datadir_rate = 'dataset_3cl/rate/';
rng(1)
windows = 2;
overlap = 1;

for isubject = [1 2]
    %% Carico i dati del primo file dello stesso paziente
    fileruns = dir([datadir_patient 'S' num2str(isubject,'%02d') 'R01.csv']);
    filename = [datadir_patient fileruns(1).name];
    T = readtable(filename);
    [m,n] = size(T);
    T = table2array(T);
    DATA = T(:,2:n-1);
    FREEZE = T(:,n);
    Fs = 64;
    
    size_windows_sec = windows;
    size_windows_sample = Fs * size_windows_sec;
    size_overlap_sec = overlap;
    size_overlap_samples = Fs * overlap;
    number_sample = 1;
    
    for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
        B = DATA(i:i+size_windows_sample-1,:);
        B=B(:);
        feature(number_sample,:)=B';
        classi(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
        number_sample = number_sample + 1;
        
    end
    for t = 1:length(classi)
        if classi(t) == 2
            classi(t) = 1;
        end
        if classi(t) == 3
            classi(t) = 2;
        end
    end
    %% Trovo il migliore k per knn
    classError_tmp=1;
    for i=1:50
        Mdl_LDA = fitcknn(feature,classi,'NumNeighbors',i,'Standardize',1);
        CVKNNMdl = crossval(Mdl_LDA);
        classError = kfoldLoss(CVKNNMdl);
        if classError_tmp > classError
            k=i;
            classError_tmp = classError;
        end
    end
    toc;
    %% Alleno il knn con il numero di vicini migliore trovato
    Mdl_LDA = fitcknn(feature,classi,'NumNeighbors',k,'Standardize',1);
    CVKNNMdl = crossval(Mdl_LDA);
    classError = kfoldLoss(CVKNNMdl)
    clear DATA FREEZE feature classi
    %% Carico i dati del secondo file dello stesso paziente
    fileruns2 = dir([datadir_patient 'S' num2str(isubject,'%02d') 'R02.csv']);
    filename2 = [datadir_patient fileruns2(1).name];
    T2 = readtable(filename2);
    [m,n] = size(T2);
    T2 = table2array(T2);
    DATA = T2(:,2:n-1);
    FREEZE = T2(:,n);
    
    size_windows_sec = windows;
    size_windows_sample = Fs * size_windows_sec;
    size_overlap_sec = overlap;
    size_overlap_samples = Fs * overlap;
    number_sample = 1;
    
    for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
        B = DATA(i:i+size_windows_sample-1,:);
        B=B(:);
        feature(number_sample,:)=B';
        classi(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
        number_sample = number_sample + 1;
        
    end
    for t = 1:length(classi)
        if classi(t) == 2
            classi(t) = 1;
        end
        if classi(t) == 3
            classi(t) = 2;
        end
    end
    %% Testo il knn
    [label,~,~] = predict(Mdl_LDA,feature);
    [C,~] = confusionmat(classi,label)
    CP = classperf(classi,label);
    rate = [CP.CorrectRate CP.Sensitivity CP.Specificity CP.PositivePredictiveValue CP.NegativePredictiveValue]
end
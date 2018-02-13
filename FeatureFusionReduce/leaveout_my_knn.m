%% Inizializzazione
% 2:4 = caviglia, 5:7 = ginocchio, 8:10 = schiena
clc;clear;
datadir = 'dataset_3cl/';

tic;
%% Creo la matrice di feature del leaveout
windows = 2;
overlap = 1;
for l = [1 2]
    number_sample = 1;
    %% Carico i dati del primo file dello stesso paziente
    for isubject = [1 2 3 5 6 7 8 9]
        fileruns = dir([datadir 'S' num2str(isubject,'%02d') 'R01.csv']);
        filename = [datadir fileruns(1).name];
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
        
        for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
            B = DATA(i:i+size_windows_sample-1,:);
            B=B(:);
            feature(number_sample,:)=B';
            classi(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
            number_sample = number_sample + 1;
            
        end
        toc;
    end
    
    %% Riduco la cardinalità delle classi
    [~,col] = find (classi == 1);
    NOFOG = feature(col,:);
    LABEL_NOFOG = classi(col)';
    [~,col] = find (classi == 2);
    FOG = feature(col,:);
    LABEL_FOG = classi(col)';
    [~,col] = find (classi == 3);
    PREFOG = feature(col,:);
    LABEL_PREFOG = classi(col)';
    
    X = 1;
    [num_fog,~] = size(FOG);
    NOFOG = NOFOG(1:X*num_fog,:);
    LABEL_NOFOG = LABEL_NOFOG(1:X*num_fog);
    
    feature = [NOFOG;PREFOG;FOG];
    classi = [LABEL_NOFOG;LABEL_PREFOG;LABEL_FOG]';
    
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
    fileruns2 = dir([datadir 'S' num2str(l,'%02d') 'R02.csv']);
    filename2 = [datadir fileruns2(1).name];
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
    %% Testo il knn
    [label,~,~] = predict(Mdl_LDA,feature);
    [C,~] = confusionmat(classi,label)
    CP = classperf(classi,label);
    rate = [CP.CorrectRate CP.Sensitivity CP.Specificity CP.PositivePredictiveValue CP.NegativePredictiveValue]
end
toc;
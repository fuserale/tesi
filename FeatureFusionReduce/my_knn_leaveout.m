%% Inizializzazione
clc; clear
tic
datadir = 'dataset_3cl/';
datadir_matrix = 'dataset_3cl/matrix/';
datadir_versus = 'dataset_3cl/versus/';
datadir_rate = 'dataset_3cl/rate/';
rng(1)
windows = 2;
overlap = 1;

for l = [1 2 3 5 6 7]
    leaveout_subject = l;
    subject = [1 2 3 5 6 7 8 9];
    for i=1:length(subject)-1
        if subject(i) == leaveout_subject
            subject(i) = [];
        end
    end
    
    number_sample = 1;
    matrix_tr = [];
    clear F class
    
    for isubject = subject
        
        fileruns = dir([datadir 'S' num2str(isubject,'%02d') 'R01.csv']);
        
        for r = 1:length(fileruns)
            
            filename = [datadir fileruns(r).name];
            T = readtable(filename);
            [m,n] = size(T);
            A = table2array(T(:,2:10));
            TIME = table2array(T(:,1));
            FREEZE = table2array(T(:,11));
            Fs = 64;
            
            %% RANGE..popolo F, vettore di range
            size_windows_sec = windows;
            size_windows_sample = Fs * size_windows_sec;
            
            size_overlap_sec = overlap;
            size_overlap_samples = Fs * overlap;
            
            
            % clear F class NOFOG LABEL_NOFOG FOG LABEL_FOG PREFOG LABEL_PREFOG
            
            for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
                B = A(i:i+size_windows_sample-1,:);
                B=B(:);
                feature(number_sample,:)=B';
                
                classi(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
                
                number_sample = number_sample + 1;
                
            end
        end
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
    
    X = 3;
    [num_fog,~] = size(FOG);
    NOFOG = NOFOG(1:X*num_fog,:);
    LABEL_NOFOG = LABEL_NOFOG(1:X*num_fog);
    
    feature = [NOFOG;PREFOG;FOG];
    classi = [LABEL_NOFOG;LABEL_PREFOG;LABEL_FOG]';
    %% Trovo il migliore k per knn
    classError_tmp=1;
    for i=1:10
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
    fileruns2 = dir([datadir 'S' num2str(leaveout_subject,'%02d') 'R02.csv']);
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
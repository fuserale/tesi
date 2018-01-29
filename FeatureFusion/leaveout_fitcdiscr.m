clc;clear;
datadir = 'dataset_3cl/';
o=0.5;  % overlap di 1 secondo (multiplo del periodo di campoionamento)
w=2;  %dimensione della finestra
leaveout = [];
tic;
for l = [1 2 3 4 5 6 7 8 9 10]
    leaveout_subject = l;
    subject = [1 2 3 4 5 6 7 8 9 10];
    for i=1:length(subject)-1
        if subject(i) == leaveout_subject
            subject(i) = [];
        end
    end
    
    number_sample = 1;
    clear F;
    clear class;
    clear F2;
    clear class2;
    
    %choose number of patients to examine (from 1 to 10)
    for isubject = subject
        
        %list of all files for patient number $isubject
        fileruns = dir([datadir 'S' num2str(isubject,'%02d') 'R01.csv']);
        
        %while there's file of patient $isubject
        for r = 1:length(fileruns)
            
            %name of the file
            filename = [datadir fileruns(r).name];
            %read table given in input
            T = readtable(filename); %csvread
            %take the dimesion
            [m,n] = size(T);
            %table to array to do maths
            A = table2array(T(:,2:10));
            TIME = table2array(T(:,1));
            FREEZE = table2array(T(:,11));
            Fs = 64;
            
            
            
            
            %% RANGE..popolo F, vettore di range
            size_windows_sec = w;
            %size of the windows in number of samples
            size_windows_sample = Fs * size_windows_sec;
            
            %overlap of the windows in seconds
            size_overlap_sec = o;
            %size of the overlap in number of samples
            size_overlap_samples = Fs * o;
            
            %for each sample window, compute the features
            
            %metto tutta la finestra (matrice 128*9) sulla stessa riga
            for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
                B = A(i:i+size_windows_sample-1,:); %B � 128 * 9 (2 secondi)
                B=B(:);
                F(number_sample,:)=B';
                
                
                %salvo la classe di ogni finestra
                class(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
                
                %go to next sample
                number_sample = number_sample + 1;
                
            end
        end
    end
    
    %% Default linear discriminant analysis (LDA)
    
    %         lda = fitcdiscr(F,class','OptimizeHyperparameters','auto',...
    %     'HyperparameterOptimizationOptions',...
    %     struct('AcquisitionFunctionName','expected-improvement-plus'))
    lda = fitcdiscr(F,class');%,'Prior','uniform');
    ldaClass = resubPredict(lda);
    ldaResubErr = resubLoss(lda);
    [ldaResubCM,~] = confusionmat(class',ldaClass)
    
    %% Predizione su altri dati
    T2 = readtable([datadir 'S' num2str(l, '%02d') 'R01.csv']);
    [m,n] = size(T2);
    A2 = table2array(T2(:,2:10));
    TIME2 = table2array(T2(:,1));
    FREEZE2 = table2array(T2(:,11));
    Fs = 64;
    number_sample = 1;
    for i=1:size_overlap_samples:m - size_windows_sample
        B2 = A2(i:i+size_windows_sample-1,:);
        [m,~] = size(B2);
        
        F2(number_sample, :) = B2(:);
        class2(number_sample) = mode(FREEZE2(i:i+size_windows_sample-1,:));
        
        number_sample = number_sample + 1;
        
    end
    %classss = classify(F2, F, class');
    label = predict(lda, F2);
    [ldaResubCM,~] = confusionmat(class2',label)
    NF = ldaResubCM(1,1)/sum(ldaResubCM(1,:));
    F = ldaResubCM(2,2)/sum(ldaResubCM(2,:));
    PF = ldaResubCM(3,3)/sum(ldaResubCM(3,:));
    accuracy = (ldaResubCM(1,1)+ldaResubCM(2,2)+ldaResubCM(3,3))/sum(sum(ldaResubCM));
    results = [size_windows_sec size_overlap_sec l NF F PF accuracy]
    leaveout = [leaveout; results];
end

writetable(array2table(leaveout), 'dataset3cl.csv');
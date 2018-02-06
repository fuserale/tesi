clc;
clear;
close all;

% 2:4 = caviglia, 5:7 = ginocchio, 8:10 = schiena
datadir = 'dataset_3cl/';

o=0.5;  % overlap di 1 secondo (multiplo del periodo di campoionamento)
w=2;  %dimensione della finestra

% clear F;
% clear Ck;
% clear class;
% clear mk;

%choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 4 5 6 7 8 9 10]
    
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
        
        tic;
        
        
        %% RANGE..popolo F, vettore di range
        size_windows_sec = w;
        %size of the windows in number of samples
        size_windows_sample = Fs * size_windows_sec;
        
        %overlap of the windows in seconds
        size_overlap_sec = o;
        %size of the overlap in number of samples
        size_overlap_samples = Fs * o;
        
        number_sample = 1;
        
        %for each sample window, compute the features
        
        %metto tutta la finestra (matrice 128*9) sulla stessa riga
        for i=1:size_windows_sample-size_overlap_samples:m - size_windows_sample
            B = A(i:i+size_windows_sample-1,:);
            
            B=B(:);
            TT(number_sample,:)=eigs(cov(B),2);
            F(number_sample,:)=B';
            
            
            
            %salvo la classe di ogni finestra
            class(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            
        end
        [V,D] = eigs(cov(F'),1);
        Z = linkage(TT,'average','euclidean');
        P = clusterdata(Z,3);
        dendrogram(Z,0,'ColorThreshold',0.7*max(Z(:,3)));
        figure; gscatter(1:length(P),P);
        title(filename);
        gscatter(1:length(TT),TT(:,1)',class);
        
        %% Default linear discriminant analysis (LDA)
        
        %         lda = fitcdiscr(F,class','OptimizeHyperparameters','auto',...
        %     'HyperparameterOptimizationOptions',...
        %     struct('AcquisitionFunctionName','expected-improvement-plus'))
        lda = fitcdiscr(F,class','Prior','uniform');
        ldaClass = resubPredict(lda);
        ldaResubErr = resubLoss(lda);
        [ldaResubCM,~] = confusionmat(class',ldaClass)
        %         figure, gscatter(lda.Mu(1,:), lda.Mu(2,:), class');
        %         legend('NoFog','Fog');
        
        %% Predizione su altri dati
        T2 = readtable([datadir 'S' num2str(isubject, '%02d') 'R02.csv']);
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
    end
end
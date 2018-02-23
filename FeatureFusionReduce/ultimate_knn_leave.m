%% Inizializzazione
clc; clear
tic
datadir = 'dataset_3cl/';
datadir_patient = 'dataset_3cl/';
datadir_matrix = 'dataset_3cl/matrix/';
datadir_versus = 'dataset_3cl/versus/';
datadir_rate = 'dataset_3cl/rate/';
rng(1)
windows = 2;
overlap = 1;

for l = [1 2 3 5 7]
    leaveout_subject = l;
    subject = [1 2 3 5 6 7 8 9];
%     for i=1:length(subject)-1
%         if subject(i) == leaveout_subject
%             subject(i) = [];
%         end
%     end
    
    number_sample = 1;
    matrix_tr = [];
    clear feature classi
    
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
    [W,Y] = LDA(feature',classi);
        Y = rescale(Y);
    for t = 1:length(classi)
        if classi(t) == 2
            classi(t) = 1;
        end
        if classi(t) == 3
            classi(t) = 2;
        end
    end
    %     figure('visible', 'on'), gscatter(Y(1,:),Y(2,:),classi);
    %     legend('NoFog+Fog','PreFog');
    %% Alleno il knn con il numero di vicini migliore trovato
    Mdl_LDA = fitcknn(Y',classi,'NumNeighbors',5,'Standardize',1);
    CVKNNMdl = crossval(Mdl_LDA);
    classError = kfoldLoss(CVKNNMdl)
    %% prova
    y = classi';
    X = Y';
    order = unique(y); % Order of the group labels
    cp = cvpartition(y,'k',10); % Stratified cross-validation
    
    f = @(xtr,ytr,xte,yte)confusionmat(yte,...
        classify(xte,xtr,ytr),'order',order);
    
    cfMat = crossval(f,X,y,'partition',cp);
    cfMat = reshape(sum(cfMat),2,2)
    clear DATA FREEZE feature classi
    %% Carico i dati del secondo file dello stesso paziente
    fileruns2 = dir([datadir_patient 'S' num2str(l,'%02d') 'R02.csv']);
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
    
    %% Testo il knn
    Y = W'*feature';
    %     [W,Y] = LDA(feature',classi);
    for t = 1:length(classi)
        if classi(t) == 2
            classi(t) = 1;
        end
        if classi(t) == 3
            classi(t) = 2;
        end
    end
    %     figure('visible', 'on'), gscatter(Y(1,:),Y(2,:),classi);
    %     legend('NoFog+Fog','PreFog');
    [label,~,~] = predict(Mdl_LDA,Y');
    [C,~] = confusionmat(classi,label)
    
    CP = classperf(classi,label);
    rate = [CP.CorrectRate CP.Sensitivity CP.Specificity]
end


%% Linear Discriminant Analysis
function [W,Y] = LDA(A,class)
[d,N] = size(A);

K =  max(class); % numero classi in gioco;

% 1. Divido le feature tramite le classi Ck
for k = 1:K
    a = find (class == k);
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
end
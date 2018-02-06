clc;clear;

% 2:4 = caviglia, 5:7 = ginocchio, 8:10 = schiena
datadir = 'dataset_3cl/';

o=0.5;  % overlap di 1 secondo (multiplo del periodo di campoionamento)
w=2;  %dimensione della finestra

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
            B = A(i:i+size_windows_sample-1,:); %B � 128 * 9 (2 secondi)
            B=B(:);
            F(number_sample,:)=B';
            
            
            %salvo la classe di ogni finestra
            class(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            
        end
        %% Linear Discriminant Analysis
        clear A;
        A=F';
        
        %quindi ho A 1152x1449 double
        %1152 finestre
        %ogni finestra ha 1449 features
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
        PR2 = [Y' class'];
        % 7: plot
        if k > 2
            figure('visible', 'on'), gscatter(Y(1,:),Y(2,:),class);
            legend('NoFog','Fog','PreFog');
        end
        if K == 2
            figure('visible', 'on'), gscatter(1:length(Y(1,:)),Y(1,:),class);
            legend('NoFog','Fog');
        end
        title(['LDA S' num2str(isubject,'%02d') ' #CLASS' num2str(K,'%01d')]);
        %savefig([datadir '/plot/LDA_S' num2str(isubject, '%02d') '_Sec' num2str(w,'%02d') '_Ov' num2str(o,'%.01f') '.fig']);
        
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
            B2 = B2(:);
            
            F2(number_sample, :) = B2;
            class2(number_sample) = mode(FREEZE2(i:i+size_windows_sample-1,:));
            
            number_sample = number_sample + 1;
            U(:,number_sample) = W'*B2;
            
        end
        U = U(:,2:end);
        
        % con tutti i dati del paziente disponibile
        % U = W'*F2';
        figure('visible', 'on'), gscatter(U(1,:),U(2,:),class2);
        legend('NoFog','Fog','PreFog');
        %% Fase di Clustering
        
        idx = kmeans(U', K);
        versus = [idx class2'];
        %writetable(array2table(versus), [datadir '/versus/versus_S' num2str(isubject,'%02d') '_Sec' num2str(w,'%02d') '_Ov' num2str(o,'%.01f') '.csv']);
        [ldaResubCM,~] = confusionmat(class2',idx)
        toc;
    end
end
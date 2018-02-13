%% Inizializzazione
% 2:4 = caviglia, 5:7 = ginocchio, 8:10 = schiena
clc;clear;
datadir = 'dataset_3cl/';

tic;
%% Creo la matrice di feature del leaveout
for windows = 2:0.5:2
    for overlap = 0.5:0.5:1
        clear F class;
        for l = [1 2 3 5 6 7 8 9]
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
                        F(number_sample,:)=B';
                        
                        class(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
                        
                        number_sample = number_sample + 1;
                        
                    end
                end
            end
            
            %% Riduco la cardinalità delle classi
            [~,col] = find (class == 1);
            NOFOG = F(col,:);
            LABEL_NOFOG = class(col)';
            [~,col] = find (class == 2);
            FOG = F(col,:);
            LABEL_FOG = class(col)';
            [~,col] = find (class == 3);
            PREFOG = F(col,:);
            LABEL_PREFOG = class(col)';
            
            X = 3;
            [num_fog,~] = size(FOG);
            NOFOG = NOFOG(1:X*num_fog,:);
            LABEL_NOFOG = LABEL_NOFOG(1:X*num_fog);
            
            F = [NOFOG;PREFOG;FOG];
            class = [LABEL_NOFOG;LABEL_PREFOG;LABEL_FOG]';
            
            %% Linear Discriminant Analysis
            clear A;
            A=F';
            [d,N] = size(A);
            
            K =  max(class);
            
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
            
            for t = 1:length(class)
               if class(t) == 2
                  class(t) = 1; 
               end
               if class(t) == 3
                  class(t) = 2; 
               end
            end
            
            % 7: plot
            if k > 2
                figure('visible', 'on'), gscatter(Y(1,:),Y(2,:),class);
                legend('NoFog+Fog','PreFog','PreFog');
            end
            if K == 2
                figure('visible', 'on'), gscatter(1:length(Y(1,:)),Y(1,:),class);
                legend('NoFog','Fog');
            end
            title(['LDA S' num2str(leaveout_subject,'%02d') ' #CLASS' num2str(K,'%01d')]);
            savefig([datadir 'LDA ALL Leaveout S' num2str(leaveout_subject,'%02d') '_Sec' num2str(windows,'%02d') '_Ov' num2str(overlap,'%.02f') '.fig']);
            
            matrix_tr = [matrix_tr; Y' class'];
            writetable(array2table(matrix_tr), [datadir 'matrix/matrix_leaveout_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            disp(['matrix/matrix_leaveout_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            
            writetable(array2table(W), [datadir 'matrix/W_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            toc;
        end
    end
end
toc;
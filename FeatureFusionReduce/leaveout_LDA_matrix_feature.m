% 2:4 = caviglia, 5:7 = ginocchio, 8:10 = schiena
clc;clear;
datadir = 'dataset_3cl/';

tic;
for windows = 1.5:0.5:2
    for overlap = 0.5:0.5:1
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
                        
                        %time sample
                        F(number_sample, 1) = TIME(i,:);
                        %min --> minimum value for each accelerometer
                        F(number_sample, 2:10) = min(B);
                        %max --> maximum value for each accelerometer
                        F(number_sample, 11:19) = max(B);
                        %median --> median signal value
                        F(number_sample, 20:28) = median(B);
                        %mean --> average value
                        F(number_sample, 29:37) = mean(B);
                        %ArmMean --> harmonic average of the signal
                        F(number_sample, 38:46) = harmmean(B);
                        %root mean square --> quadratic mean value of the signal
                        F(number_sample, 47:55) = rms(B);
                        %variance --> square of the standard deviation
                        F(number_sample, 56:64) = var(B);
                        %standard deviation --> mean deviation of the signal compared to the
                        %average
                        F(number_sample, 65:73) = std(B);
                        %kurtosis --> degree of peakedness of the sensor signal distribution
                        %(allontanamento dalla normalità distributiva)
                        F(number_sample, 74:82) = kurtosis(B);
                        %skewdness --> degree of asymmetry of the sensor signal distribution
                        F(number_sample, 83:91) = skewness(B);
                        %mode --> number that appears most often in the signal
                        F(number_sample, 92:100) = mode(B);
                        %trim mean --> trimmed mean of the signal in the window
                        F(number_sample, 101:109) = trimmean(B,10);
                        %range --> difference between the largest and the smallest values of
                        %the signal
                        F(number_sample, 110:118) = range(B);
                        %signal magnitude vector --> sum of the euclidean norm over the three
                        %axis over the entire window normalized by the windows lenght
                        F(number_sample, 119) = svmn(B(:,1:3), length(B));
                        F(number_sample, 120) = svmn(B(:,4:6), length(B));
                        F(number_sample, 121) = svmn(B(:,7:9), length(B));
                        %normalized signal magnitude area --> acceleration magnitude summed
                        %over three axes normalized by the windows length
                        F(number_sample, 122) = sman(B(:,1:3), length(B));
                        F(number_sample, 123) = sman(B(:,4:6), length(B));
                        F(number_sample, 124) = sman(B(:,7:9), length(B));
                        %eigenvalues of dominant directions --> eigenvalues of the
                        %covariance matrix of the acceleration data along x, y and z axis
                        F(number_sample,125) = eigs(cov(B(:,1:3)),1);
                        F(number_sample,126) = eigs(cov(B(:,4:6)),1);
                        F(number_sample,127) = eigs(cov(B(:,7:9)),1);
                        %averaged acceleration energy --> mean value of the energy over
                        %three acceleration axes
                        F(number_sample,128) = energyn(B(:,1:3),length(B));
                        F(number_sample,129) = energyn(B(:,4:6),length(B));
                        F(number_sample,130) = energyn(B(:,7:9),length(B));
                        %is freezing?
                        class(number_sample) = mode(FREEZE(i:i+size_windows_sample-1,:));
                        
                        %go to next sample
                        number_sample = number_sample + 1;
                        
                    end
                end
            end
            F = F(:,2:130);

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
            
            for p=1:d
                for o=1:N
                   if(isnan(A(p,o)))
                       A(p,o) = 0;
                   end
                end
            end
            
            K =  max(class);
            
            % 1. Divido le feature tramite le classi Ck
            for k = 1:K
                a = find (class == k);
                Ck{k} = A(:, a);
            end
            
            % 2. Calcolo la media per ogni classe per ogni finestra
            for k = 1:K
                mk{k} = nanmean(Ck{k},2);
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
            
            % 7: plot
            if k > 2
                figure('visible', 'on'), gscatter(Y(1,:),Y(2,:),class);
                legend('NoFog','Fog','PreFog');
            end
            if K == 2
                figure('visible', 'on'), gscatter(1:length(Y(1,:)),Y(1,:),class);
                legend('NoFog','Fog');
            end
            title(['LDA S' num2str(leaveout_subject,'%02d') ' #CLASS' num2str(K,'%01d')]);
            savefig([datadir 'LDA feature ALL Leaveout S' num2str(leaveout_subject,'%02d') '_Sec' num2str(windows,'%02d') '_Ov' num2str(overlap,'%.02f') '.fig']);
            
            matrix_tr = [matrix_tr; Y' class'];
            writetable(array2table(matrix_tr), [datadir 'matrix/matrix_feature_leaveout_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            disp(['matrix/matrix_leaveout_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            
            writetable(array2table(W), [datadir 'matrix/W_feature_S' num2str(leaveout_subject,'%02d') '_second' num2str(windows,'%.01f') '_overlap' num2str(overlap,'%.01f') '.csv']);
            toc;
        end
    end
end
toc;

function svm = svmn(X, windows_length)
sum1 = norm(X);
svm = sum1 / windows_length;
end

function sma = sman(X, windows_length)
[m,~] = size(X);
sum = 0;
for i=1:m
    sum = sum + (abs(X(i,1)) + abs(X(i,2)) + abs(X(i,3)));
end
sma = sum / windows_length;
end

function energy = energyn(X, windows_length)
sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
energy = sum1 / windows_length;
end
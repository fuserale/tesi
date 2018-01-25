
function featureDynamics_2cl(u,o)

datadir_original = '../../';
datadir_feature = '../../dataset/';

%% choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 4 8]
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir_original '3cl_S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        %% Caricamento dei file
        %name of the file
        filename = [datadir_original fileruns(r).name];
        %read table given in input
        T = readtable(filename);
        %take the dimesion
        [m,~] = size(T);
        %table to array to do maths
        A = table2array(T(:,2:10));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        B = [];
        
        number_sample = 1;
        end_size = 1;
        i = 1;
        Fs = 64;
        
        %% uso del filtro passa-alto
        fhp = hpfilter;
        A = filter(fhp,A);
        %%
        
        %decisione dell'intervallo della finestra massima
        number_seconds = u;
        windows_samples = Fs * number_seconds;
        %decisione dell'intervallo di sovrapposizione
        number_seconds2 = o;
        sovrapposition_samples = Fs * number_seconds2;
        
        %for each sample window, compute the features
        while i < m
            
            indx = FREEZE(i,1);
            temp = indx;
            end_size = i;
            while ((indx == temp) && (end_size < windows_samples + i) && (end_size < m))
                end_size = end_size + 1;
                temp = FREEZE(end_size,1);
            end
            B = A(i:end_size-1,:);
            
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
            F(number_sample,131) = mode(FREEZE(i:end_size,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            if (end_size == m)
                break;
            end
            i = end_size;
        end
        %gplotmatrix(F,F,F(:,50));
        P = array2table(F);
        %P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX' 'MINACCY' 'MINACCZ' 'MAXACCX' 'MAXACCY' 'MAXACCZ' 'MEDIANACCX' 'MEDIANACCY' 'MEDIANACCZ' 'MEANACCX' 'MEANACCY' 'MEANACCZ' 'ARMEMANX' 'ARMMEANY' 'ARMMEANZ' 'RMSX' 'RMSY' 'RMSZ' 'VARX' 'VARY' 'VARZ' 'STDX' 'STDY' 'STDZ' 'KURTX' 'KURTY' 'KURTZ' 'SKEWX' 'SKEWY' 'SKEWZ' 'MODEX' 'MODEY' 'MODEZ' 'TRIMX' 'TRIMY' 'TRIMZ' 'RANGEX' 'RANGEY' 'RANGEZ' 'SMV' 'SMA' 'EVA' 'AAE' 'FREEZE'};
        writetable(P, [datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        display([datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        F(:,:) = [];
        
    end
end
end
%% --- Function
function svm = svmn(X, windows_length)
[m,n] = size(X);
sum = 0;
for i=1:m
    sum = sum + sqrt(X(i,1)^2 + X(i,2)^2 + X(i,3)^2);
end
svm = sum / windows_length;
end

function sma = sman(X, windows_length)
[m,n] = size(X);
sum = 0;
for i=1:m
    sum = sum + (abs(X(i,1)) + abs(X(i,2)) + abs(X(i,3)));
end
sma = sum / windows_length;
end

function energy = energyn(X, windows_length)
[m,n] = size(X);
sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
energy = sum1 / windows_length;
end

function velocity = velocityn(X)
[m1,~] = size(X);
for i = 1:m1
    n(i,:) = norm(X(i,:));
end
velocity = trapz(n) / m1;
end

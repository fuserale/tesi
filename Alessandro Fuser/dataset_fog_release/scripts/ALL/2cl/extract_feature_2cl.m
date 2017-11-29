clear; clc

datadir = '../../../dataset/CSV/';

%choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 4 8]
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir '2cl_S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        
        %name of the file
        filename = [datadir fileruns(r).name];
        %read table given in input
        T = readtable(filename);
        %take the dimesion
        [m,n] = size(T);
        %table to array to do maths
        A = table2array(T(:,2:10));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        Fs = 64;
        
        %size of the windows in seconds
        for k = 5:5:45
            
            Y = k/10;
            
            for i = (Y+0.5):0.5:5
                size_windows_sec = i;
                %size of the windows in number of samples
                size_windows_sample = Fs * i;
                
                %overlap of the windows in seconds
                size_overlap_sec = Y;
                %size of the overlap in number of samples
                size_overlap_samples = Fs * Y;
                
                number_sample = 1;
                
                %for each sample window, compute the features
                for i=1:size_overlap_samples:m - size_overlap_samples
                    B = A(i:i+size_overlap_samples-1,:);
                    
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
                    F(number_sample,131) = mode(FREEZE(i:i+size_overlap_samples-1,:));
                    
                    %go to next sample
                    number_sample = number_sample + 1;
                    
                end
                
                
                P = array2table(F);
                P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX1' 'MINACCY1' 'MINACCZ1' 'MINACCX2' 'MINACCY2' 'MINACCZ2' 'MINACCX3' 'MINACCY3' 'MINACCZ3' 'MAXACCX1' 'MAXACCY1' 'MAXACCZ1' 'MAXACCX2' 'MAXACCY2', 'MAXACCZ2' 'MAXACCX3' 'MAXACCY3' 'MAXACCZ3' 'MEDIANACCX1' 'MEDIANACCY1' 'MEDIANACCZ1' 'MEDIANACCX2' 'MEDIANACCY2' 'MEDIANACCZ2' 'MEDIANACCX3' 'MEDIANACCY3' 'MEDIANACCZ3' 'MEANACCX1' 'MEANACCY1' 'MEANACCZ1' 'MEANCACCX2' 'MEANACCY2' 'MEANACCZ2' 'MEANACCX3' 'MEANACCY3' 'MEANACCZ3' 'ARMEMANX1' 'ARMMEANY1' 'ARMMEANZ1' 'ARMMEANX2' 'ARMMEANY2' 'ARMMEANZ2' 'ARMMEANX3' 'ARMMEANY3' 'ARMMEANZ3' 'RMSX1' 'RMSY1' 'RMSZ1' 'RMSX2' 'RMSY2' 'RMSZ2' 'RMSX3' 'RMSY3' 'RMSZ3' 'VARX1' 'VARY1' 'VARZ1' 'VARX2' 'VARY2' 'VARZ2' 'VARX3' 'VARY3' 'VARZ3' 'STDX1' 'STDY1' 'STDZ1' 'STDX2' 'STDY2' 'STDZ2' 'STDX3' 'STDY3' 'STDZ3' 'KURTX1' 'KURTY1' 'KURTZ1' 'KURTX2' 'KURTY2' 'KURTZ2' 'KURTX3' 'KURTY3' 'KURTZ3' 'SKEWX1' 'SKEWY1' 'SKEWZ1' 'SKEWX2' 'SKEWY2' 'SKEWZ2' 'SKEWX3' 'SKEWY3' 'SKEWZ3' 'MODEX1' 'MODEY1' 'MODEZ1' 'MODEX2' 'MODEY2' 'MODEZ2' 'MODEX3' 'MODEY3' 'MODEZ3' 'TRIMX1' 'TRIMY1' 'TRIMZ1' 'TRIMX2' 'TRIMY2' 'TRIMZ2' 'TRIMX3' 'TRIMY3' 'TRIMZ3' 'RANGEX1' 'RANGEY1' 'RANGEZ1' 'RANGEX2' 'RANGEY2' 'RANGEZ2' 'RANGEX3' 'RANGEY3' 'RANGEZ3' 'SMV1' 'SMV2' 'SMV3' 'SMA1' 'SMA2' 'SMA3' 'EVA1' 'EVA2' 'EVA3' 'AAE1' 'AAE2' 'AAE3' 'FREEZE'};
                writetable(P, ['../../../dataset/CSV/feature/interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(k,2) '/2cl_feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                display(['2cl_feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                F(:,:) = [];
            end
        end
        
    end
end

function svm = svmn(X, windows_length)
[m,n] = size(X);
sum1 = norm(X);
svm = sum1 / windows_length;
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
sum1 = 0;
sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
energy = sum1 / windows_length;
end

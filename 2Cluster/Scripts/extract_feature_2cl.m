clear; clc

datadir = '../dataset/';

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
        
        fhp = hpfilter;
        A = filter(fhp,A); 
        
        A = zscore(A);
        
        %size of the windows in seconds
        for k = 5:5:45
            
            Y = k/10;
            
            for i = (Y+0.5):0.5:5
                size_windows_sec = i;
                %size of the windows in number of samples
                size_windows_sample = Fs * size_windows_sec;
                
                %overlap of the windows in seconds
                size_overlap_sec = Y;
                %size of the overlap in number of samples
                size_overlap_samples = Fs * size_overlap_sec;
                
                number_sample = 1;
                
                %for each sample window, compute the features
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
                    F(number_sample,131) = mode(FREEZE(i:i+size_windows_sample-1,:));
                    
                    %go to next sample
                    number_sample = number_sample + 1;
                    
                end
                
                
                P = array2table(F);
                writetable(P, ['../interval_2cl/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(k,2) '/2cl_feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                display(['2cl_feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                F(:,:) = [];
            end
        end
        
    end
end

function svm = svmn(X, windows_length)
sum1 = norm(X);
svm = sum1 / windows_length;
end

function sma = sman(X, windows_length)
sum = 0;
[m,~] = size(X);
for i=1:m
    sum = sum + (abs(X(i,1)) + abs(X(i,2)) + abs(X(i,3)));
end
sma = sum / windows_length;
end

function energy = energyn(X, windows_length)
sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
energy = sum1 / windows_length;
end

clear; clc

datadir = '../../dataset/CSV/';

%choose number of patients to examine (from 1 to 10)
for isubject = 5:5
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir 'S' num2str(isubject,'%02d') 'R01.csv']);
    
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
        
        %size of the windows in seconds
        for k = 5:5:45
            
            Y = k/10;
            
            for i = (Y+0.5):0.5:5
                size_windows_sec = i;
                %size of the windows in number of samples
                size_windows_sample = (size_windows_sec*1000)/15;
                
                %overlap of the windows in seconds
                size_overlap_sec = Y;
                %size of the overlap in number of samples
                size_overlap_samples = (size_overlap_sec * 1000)/15;
                
                number_sample = 1;
                
                %for each sample window, compute the features
                for i=1:floor(size_overlap_samples):m - floor(size_overlap_samples)
                    B = A(i:i+floor(size_overlap_samples)-1,:);
                    
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
                    %entropy --> measure of the distribution of frequency components
                    F(number_sample, 110:118) = entropy(B);
                    %range --> difference between the largest and the smallest values of
                    %the signal
                    F(number_sample, 119:127) = range(B);
                    %signal magnitude vector --> sum of the euclidean norm over the three
                    %axis over the entire window normalized by the windows lenght
                    F(number_sample, 128) = svmn(B(:,1:3), size_windows_sample);
                    F(number_sample, 129) = svmn(B(:,4:6), size_windows_sample);
                    F(number_sample, 130) = svmn(B(:,7:9), size_windows_sample);
                    %normalized signal magnitude area --> acceleration magnitude summed
                    %over three axes normalized by the windows length
                    F(number_sample, 131) = sman(B(:,1:3), size_windows_sample);
                    F(number_sample, 132) = sman(B(:,4:6), size_windows_sample);
                    F(number_sample, 133) = sman(B(:,7:9), size_windows_sample);
                    %eigenvalues of dominant directions --> eigenvalues of the
                    %covariance matrix of the acceleration data along x, y and z axis
                    F(number_sample,134) = eigs(cov(B(:,1:3)),1);
                    F(number_sample,135) = eigs(cov(B(:,4:6)),1);
                    F(number_sample,136) = eigs(cov(B(:,7:9)),1);
                    %averaged acceleration energy --> mean value of the energy over
                    %three acceleration axes
                    F(number_sample,137) = energyn(B(:,1:3),size_windows_sample);
                    F(number_sample,138) = energyn(B(:,4:6),size_windows_sample);
                    F(number_sample,139) = energyn(B(:,7:9),size_windows_sample);
                    %freezing index
                    [F(number_sample,140),F(number_sample,141)] = freezingindex(B(:,1), 64, size_windows_sample, isubject);
                    [F(number_sample,142),F(number_sample,143)] = freezingindex(B(:,2), 64, size_windows_sample, isubject);
                    [F(number_sample,144),F(number_sample,145)] = freezingindex(B(:,3), 64, size_windows_sample, isubject);
                    [F(number_sample,146),F(number_sample,147)] = freezingindex(B(:,4), 64, size_windows_sample, isubject);
                    [F(number_sample,148),F(number_sample,149)] = freezingindex(B(:,5), 64, size_windows_sample, isubject);
                    [F(number_sample,150),F(number_sample,151)] = freezingindex(B(:,6), 64, size_windows_sample, isubject);
                    [F(number_sample,152),F(number_sample,153)] = freezingindex(B(:,7), 64, size_windows_sample, isubject);
                    [F(number_sample,154),F(number_sample,155)] = freezingindex(B(:,8), 64, size_windows_sample, isubject);
                    [F(number_sample,156),F(number_sample,157)] = freezingindex(B(:,9), 64, size_windows_sample, isubject);
                    %is freezing?
                    F(number_sample,158) = round(mean(FREEZE(i:i+floor(size_overlap_samples)-1,:)));
                    
                    %go to next sample
                    number_sample = number_sample + 1;
                    
                end
                
                
                P = array2table(F);
                P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX1' 'MINACCY1' 'MINACCZ1' 'MINACCX2' 'MINACCY2' 'MINACCZ2' 'MINACCX3' 'MINACCY3' 'MINACCZ3' 'MAXACCX1' 'MAXACCY1' 'MAXACCZ1' 'MAXACCX2' 'MAXACCY2', 'MAXACCZ2' 'MAXACCX3' 'MAXACCY3' 'MAXACCZ3' 'MEDIANACCX1' 'MEDIANACCY1' 'MEDIANACCZ1' 'MEDIANACCX2' 'MEDIANACCY2' 'MEDIANACCZ2' 'MEDIANACCX3' 'MEDIANACCY3' 'MEDIANACCZ3' 'MEANACCX1' 'MEANACCY1' 'MEANACCZ1' 'MEANCACCX2' 'MEANACCY2' 'MEANACCZ2' 'MEANACCX3' 'MEANACCY3' 'MEANACCZ3' 'ARMEMANX1' 'ARMMEANY1' 'ARMMEANZ1' 'ARMMEANX2' 'ARMMEANY2' 'ARMMEANZ2' 'ARMMEANX3' 'ARMMEANY3' 'ARMMEANZ3' 'RMSX1' 'RMSY1' 'RMSZ1' 'RMSX2' 'RMSY2' 'RMSZ2' 'RMSX3' 'RMSY3' 'RMSZ3' 'VARX1' 'VARY1' 'VARZ1' 'VARX2' 'VARY2' 'VARZ2' 'VARX3' 'VARY3' 'VARZ3' 'STDX1' 'STDY1' 'STDZ1' 'STDX2' 'STDY2' 'STDZ2' 'STDX3' 'STDY3' 'STDZ3' 'KURTX1' 'KURTY1' 'KURTZ1' 'KURTX2' 'KURTY2' 'KURTZ2' 'KURTX3' 'KURTY3' 'KURTZ3' 'SKEWX1' 'SKEWY1' 'SKEWZ1' 'SKEWX2' 'SKEWY2' 'SKEWZ2' 'SKEWX3' 'SKEWY3' 'SKEWZ3' 'MODEX1' 'MODEY1' 'MODEZ1' 'MODEX2' 'MODEY2' 'MODEZ2' 'MODEX3' 'MODEY3' 'MODEZ3' 'TRIMX1' 'TRIMY1' 'TRIMZ1' 'TRIMX2' 'TRIMY2' 'TRIMZ2' 'TRIMX3' 'TRIMY3' 'TRIMZ3' 'ENTROPYX1' 'ENTROPYY1' 'ENTROPYZ1' 'ENTROPYX2' 'ENTROPYY2' 'ENTROPYZ2' 'ENTROPYX3' 'ENTROPYY3' 'ENTROPYZ3' 'RANGEX1' 'RANGEY1' 'RANGEZ1' 'RANGEX2' 'RANGEY2' 'RANGEZ2' 'RANGEX3' 'RANGEY3' 'RANGEZ3' 'SMV1' 'SMV2' 'SMV3' 'SMA1' 'SMA2' 'SMA3' 'EVA1' 'EVA2' 'EVA3' 'AAE1' 'AAE2' 'AAE3' 'FIX1' 'SLF1' 'FIY1' 'SLFY1' 'FIZ1' 'SLFZ1' 'FIX2' 'SLFX2' 'FIY2' 'SLFY2' 'FIZ2' 'SLFZ2' 'FIX3' 'SLFX3' 'FIY3' 'SLFY3' 'FIZ3' 'SLFZ3' 'FREEZE'};
                writetable(P, ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(k,2) '/feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                display(['feature_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
                F(:,:) = [];
            end
        end
        
    end
end

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
    sum = sum + (X(i,1) + X(i,2) + X(i,3));
end
sma = sum / windows_length;
end

function energy = energyn(X, windows_length)
[m,n] = size(X);
sum = 0;
sum = sum + (mean(fft(X(:,1)).*conj(fft(X(:,1))) + fft(X(:,2)).*conj(fft(X(:,2))) + fft(X(:,3)).*conj(fft(X(:,3)))));
energy = sum / windows_length;
end

function [FI, SLF] = freezingindex(X, SR, windows_length, isubject)
TH.freeze  =  [3 1.5 3 1.5 1.5 1.5 3 3 1.5 3];
TH.power   = 2.^ 12 ; %4096
NFFT = 256;
locoBand=[0.5 3];
freezeBand=[3 8];

f_res = SR / NFFT;
f_nr_LBs  = round(locoBand(1)   / f_res);
f_nr_LBs( f_nr_LBs==0 ) = [];
f_nr_LBe  = round(locoBand(2)   / f_res);
f_nr_FBs  = round(freezeBand(1) / f_res);
f_nr_FBe  = round(freezeBand(2) / f_res);

d = NFFT/2;

[m,n] = size(X);

% Compute FFT
Y = fft(X);
Pyy = Y.* conj(Y) / SR;

% --- calculate sumLocoFreeze and freezeIndex ---
areaLocoBand   = x_numericalIntegration( Pyy(f_nr_LBs:f_nr_LBe),SR );
areaFreezeBand = x_numericalIntegration( Pyy(f_nr_FBs:f_nr_FBe),SR );

sumLocoFreeze = areaFreezeBand + areaLocoBand;

freezeIndex = areaFreezeBand/areaLocoBand;
% --------------------

if sumLocoFreeze < TH.power
    freezeIndex = 0;
end

%          lframe = (freezeIndex>TH.freeze(isubject));
FI = freezeIndex;
SLF = sumLocoFreeze;

end

clear; clc

datadir_original = '../../../../';
datadir_feature = '../../dataset/';

%choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 4 8]
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir_original '3cl_S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        
        %name of the file
        filename = [datadir_original fileruns(r).name];
        %read table given in input
        T = readtable(filename);
        %take the dimesion
        [m,n] = size(T);
        %table to array to do maths
        A = table2array(T(:,2:4));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        B = [];
        
        number_sample = 1;
        indx = 0;
        end_size = 1;
        i = 1;
        
        %decisione dell'intervallo della finestra massima
        number_seconds = 2;
        number_samples = round(number_seconds / 0.015);
        %decisione dell'intervallo di sovrapposizione
        number_seconds2 = number_seconds / 2;
        number_samples2 = round(number_seconds2 / 0.015);
        
        %for each sample window, compute the features
        while i < m
            i = end_size;
            indx = FREEZE(i,1);
            temp = indx;
            end_size = i;
            while ((indx == temp) && (end_size < number_samples + i) && (end_size < m))
                end_size = end_size + 1;
                temp = FREEZE(end_size,1);
            end
            B = A(i:end_size-1,:);
            
            %time sample
            F(number_sample, 1) = TIME(i,:);
            %min --> minimum value for each accelerometer
            F(number_sample, 2:4) = min(B);
            %max --> maximum value for each accelerometer
            F(number_sample, 5:7) = max(B);
            %median --> median signal value
            F(number_sample, 8:10) = median(B);
            %mean --> average value
            F(number_sample, 11:13) = mean(B);
            %ArmMean --> harmonic average of the signal
            F(number_sample, 14:16) = harmmean(B);
            %root mean square --> quadratic mean value of the signal
            F(number_sample, 17:19) = rms(B);
            %variance --> square of the standard deviation
            F(number_sample, 20:22) = var(B);
            %standard deviation --> mean deviation of the signal compared to the
            %average
            F(number_sample, 23:25) = std(B);
            %kurtosis --> degree of peakedness of the sensor signal distribution
            %(allontanamento dalla normalità distributiva)
            F(number_sample, 26:28) = kurtosis(B);
            %skewdness --> degree of asymmetry of the sensor signal distribution
            F(number_sample, 29:31) = skewness(B);
            %mode --> number that appears most often in the signal
            F(number_sample, 32:34) = mode(B);
            %trim mean --> trimmed mean of the signal in the window
            F(number_sample, 35:37) = trimmean(B,10);
            %range --> difference between the largest and the smallest values of
            %the signal
            F(number_sample, 38:40) = range(B);
            %signal magnitude vector --> sum of the euclidean norm over the three
            %axis over the entire window normalized by the windows lenght
            F(number_sample, 41) = svmn(B(:,1:3), length(B));
            %normalized signal magnitude area --> acceleration magnitude summed
            %over three axes normalized by the windows length
            F(number_sample, 42) = sman(B(:,1:3), length(B));
            %eigenvalues of dominant directions --> eigenvalues of the
            %covariance matrix of the acceleration data along x, y and z axis
            F(number_sample,43) = eigs(cov(B(:,1:3)),1);
            %averaged acceleration energy --> mean value of the energy over
            %three acceleration axes
            F(number_sample,44) = energyn(B(:,1:3),length(B));
            %is freezing?
            F(number_sample,45) = mode(FREEZE(i:end_size-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            if (end_size == m)
                break;
            end   
        end
        
        P = array2table(F);
        P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX' 'MINACCY' 'MINACCZ' 'MAXACCX' 'MAXACCY' 'MAXACCZ' 'MEDIANACCX' 'MEDIANACCY' 'MEDIANACCZ' 'MEANACCX' 'MEANACCY' 'MEANACCZ' 'ARMEMANX' 'ARMMEANY' 'ARMMEANZ' 'RMSX' 'RMSY' 'RMSZ' 'VARX' 'VARY' 'VARZ' 'STDX' 'STDY' 'STDZ' 'KURTX' 'KURTY' 'KURTZ' 'SKEWX' 'SKEWY' 'SKEWZ' 'MODEX' 'MODEY' 'MODEZ' 'TRIMX' 'TRIMY' 'TRIMZ' 'RANGEX' 'RANGEY' 'RANGEZ' 'SMV' 'SMA' 'EVA' 'AAE' 'FREEZE'};        
        writetable(P, [datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        display([datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        F(:,:) = [];
        
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
    sum = sum + (abs(X(i,1)) + abs(X(i,2)) + abs(X(i,3)));
end
sma = sum / windows_length;
end

function energy = energyn(X, windows_length)
[m,n] = size(X);
sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
energy = sum1 / windows_length;
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

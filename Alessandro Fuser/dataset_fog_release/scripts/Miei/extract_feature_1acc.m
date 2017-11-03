clear; clc

datadir = '../../dataset/CSV/';
    
    %choose number of patients to examine (from 1 to 10)
    for isubject = 4
        
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
            % 2:4 = acc1; 5:7 = acc2; 8:10 = acc3
            A = table2array(T(:,8:10));
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
                %entropy --> measure of the distribution of frequency components
                F(number_sample, 38:40) = entropy(B);
                %range --> difference between the largest and the smallest values of
                %the signal
                F(number_sample, 41:43) = range(B);
                %signal magnitude vector --> sum of the euclidean norm over the three
                %axis over the entire window normalized by the windows lenght
                F(number_sample, 44) = svmn(B(:,1:3), size_windows_sample);
                %normalized signal magnitude area --> acceleration magnitude summed
                %over three axes normalized by the windows length
                F(number_sample, 45) = sman(B(:,1:3), size_windows_sample);
                %eigenvalues of dominant directions --> eigenvalues of the
                %covariance matrix of the acceleration data along x, y and z axis
                F(number_sample, 46) = eigs(cov(B(:,1:3)),1);
                %averaged acceleration energy --> mean value of the energy over
                %three acceleration axes
                F(number_sample, 47) = energyn(B(:,1:3),size_windows_sample);
                %freezing index
                [F(number_sample, 48),F(number_sample,49)] = freezingindex(B(:,1), 64, size_windows_sample, isubject);
                [F(number_sample, 50),F(number_sample,51)] = freezingindex(B(:,2), 64, size_windows_sample, isubject); 
                [F(number_sample, 52),F(number_sample,53)] = freezingindex(B(:,3), 64, size_windows_sample, isubject); 
                %is freezing?
                F(number_sample, 54) = round(mean(FREEZE(i:i+floor(size_overlap_samples)-1,:)));

                %go to next sample
                number_sample = number_sample + 1;
               
            end
            
            
            P = array2table(F);
            P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX' 'MINACCY' 'MINACCZ' 'MAXACCX' 'MAXACCY' 'MAXACCZ' 'MEDIANACCX' 'MEDIANACCY' 'MEDIANACCZ' 'MEANACCX' 'MEANACCY' 'MEANACCZ' 'ARMEMANX' 'ARMMEANY' 'ARMMEANZ' 'RMSX' 'RMSY' 'RMSZ' 'VARX' 'VARY' 'VARZ' 'STDX' 'STDY' 'STDZ' 'KURTX' 'KURTY' 'KURTZ' 'SKEWX' 'SKEWY' 'SKEWZ' 'MODEX' 'MODEY' 'MODEZ' 'TRIMX' 'TRIMY' 'TRIMZ' 'ENTROPYX' 'ENTROPYY' 'ENTROPYZ' 'RANGEX' 'RANGEY' 'RANGEZ' 'SMV' 'SMA' 'EVA' 'AAE' 'FIX' 'SLFX' 'FIY' 'SLFY' 'FIZ' 'SLFZ' 'FREEZE'};
            writetable(P, ['../../dataset/CSV/feature/interval/S' num2str(isubject,'%02d') 'R01/overlap_' num2str(k,2) '/feature_1acc_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
            display(['feature_1acc_sec' num2str(size_windows_sec*10,2) '_ov' num2str(k,2) '_' fileruns(r).name ]);
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
        sum = sum / windows_length;
        svm = sum;
    end

    function sma = sman(X, windows_length)
        [m,n] = size(X);
        sum = 0;
        for i=1:m
            sum = sum + (X(i,1) + X(i,2) + X(i,3));
        end
        sum = sum / windows_length;
        sma = sum;
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
        windowLength=256;
        
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

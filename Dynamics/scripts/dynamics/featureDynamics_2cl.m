
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
        [m,n] = size(T);
        TA = table2array(T);
        %table to array to do maths
        A = table2array(T(:,2:4));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        B = [];
        
        %trasformazione dell'accelerazione da mg (milli-gravity) to m/s^2
        A = A / 1000 * 9.81;
        
        number_sample = 1;
        indx = 0;
        end_size = 1;
        i = 1;
        Fs = 64;
        
        %% uso del filtro passa-alto
        fhp = hpfilter;
        A = filter(fhp,A); 
        
%         %% prova col pwelch per vedere su quali assi ho le differenze
%         sel1 = TA(:,11) == 1 & TA(:,1) < 1137765 & TA(:,1) > 1137765-2000;
%         sel2 = TA(:,11) == 3 & TA(:,1) < 1152765;
%         sel3 = TA(:,11) == 2 & TA(:,1) < 1152765+2000;
%         asse = 10;
%         nofog = TA(sel1,:);
%         figure
%         pwelch(nofog(:,asse),[],[],[],Fs);
%         prefog = TA(sel2,:);
%         figure
%         pwelch(prefog(:,asse),[],[],[],Fs);
%         fog = TA(sel3,:);
%         figure
%         pwelch(fog(:,asse),[],[],[],Fs);         
        %%
        
        %decisione dell'intervallo della finestra massima
        number_seconds = u;
        number_samples = Fs * number_seconds;
        %decisione dell'intervallo di sovrapposizione
        number_seconds2 = o;
        number_samples2 = Fs * number_seconds2;
        
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
            %velocity
            F(number_sample,45) = velocityn(B(:,1:3));
            %position
            F(number_sample,46) = trapz(F(:,45));
            %F(number_sample,47:49) = freezingindex(B,Fs,length(B),isubject);
            %is freezing?
            F(number_sample,47) = mode(FREEZE(i:end_size-1,:));

%             %time sample
%             F(number_sample, 1) = TIME(i,:);
%             % Average value in signal buffer for all three acceleration components (1 each)
%             F(number_sample,2:4) = mean(B(:,1:3),1);
% 
%             % RMS value in signal buffer for all three acceleration components (1 each)
%             F(number_sample,5:7) = rms(B(:,1:3),1);
% 
%             % Spectral peak features (12 each): height and position of first 6 peaks
%             F(number_sample,8:43) = spectralPeaksFeatures(B(:,1:3), Fs);
% 
%             % Autocorrelation features for all three acceleration components (3 each):
%             % height of main peak; height and position of second peak
%             F(number_sample,44:52) = autocorrFeatures(B(:,1:3), Fs);
% 
%             % Spectral power features (5 each): total power in 5 adjacent
%             % and pre-defined frequency bands
%             F(number_sample,8:28) = spectralPowerFeatures(B(:,1:3), Fs);
%             F(number_sample,29) = mode(FREEZE(i:end_size-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            if (end_size == m)
                break;
            end   
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

function FI = freezingindex(X, SR, windows_length, isubject)
% TH.freeze  =  [3 1.5 3 1.5 1.5 1.5 3 3 1.5 3];
% TH.power   = 2.^ 12 ; %4096
% NFFT = 128;
% locoBand=[0.5 3];
% freezeBand=[3 8];
% 
% f_res = SR / NFFT;
% f_nr_LBs  = round(locoBand(1)   / f_res);
% f_nr_LBs( f_nr_LBs==0 ) = [];
% f_nr_LBe  = round(locoBand(2)   / f_res);
% f_nr_FBs  = round(freezeBand(1) / f_res);
% f_nr_FBe  = round(freezeBand(2) / f_res);
% 
% % d = NFFT/2;
% 
% % [m,n] = size(X);
% X = X - mean(X);
% 
% % Compute FFT
% Y = fft(X);
% Pyy = Y.* conj(Y) / SR;
% 
% % --- calculate sumLocoFreeze and freezeIndex ---
% areaLocoBand   = x_numericalIntegration( Pyy(f_nr_LBs:f_nr_LBe),SR );
% areaFreezeBand = x_numericalIntegration( Pyy(f_nr_FBs:f_nr_FBe),SR );
% 
% sumLocoFreeze = areaFreezeBand + areaLocoBand;
% 
% freezeIndex = areaFreezeBand/areaLocoBand;
% % --------------------
% 
% % if sumLocoFreeze < TH.power
% %     freezeIndex = 0;
% % end
% 
% % lframe = (freezeIndex>TH.freeze(isubject));
% FI = freezeIndex;
% SLF = sumLocoFreeze;
[m,n] = size(X);
res = x_fi(X, SR, m);
FI = res.quot;
end

%% --- Helper functions
function feats = spectralPeaksFeatures(x, fs)

feats = zeros(1,3*12);
N = 4096;

mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(fs/N));

% Cycle through number of channels
nfinalpeaks = 6;
for k = 1:3
    [xpsd, f] = pwelch(x(:,k),rectwin(length(x)),[],N,fs);
    [pks,locs] = findpeaks(xpsd,'npeaks',20,'minpeakdistance',minpkdist);
    opks = zeros(nfinalpeaks,1);
    if(~isempty(pks))
        mx = min(6,length(pks));
        [spks, idx] = sort(pks,'descend');
        slocs = locs(idx);
        
        pkssel = spks(1:mx);
        locssel = slocs(1:mx);
        
        [olocs, idx] = sort(locssel,'ascend');
        opks = pkssel(idx);
    end
    ofpk = f(olocs);
    
    % Features 1-6 positions of highest 6 peaks
    feats(12*(k-1)+(1:length(opks))) = ofpk;
    % Features 7-12 power levels of highest 6 peaks
    feats(12*(k-1)+(7:7+length(opks)-1)) = opks;
end
end

function feats = autocorrFeatures(x, fs)

feats = zeros(1,3*3);

minprom = 0.0005;
mindist_xunits = 0.2;
minpkdist = floor(mindist_xunits/(1/fs));

% Separate peak analysis for 3 different channels
for k = 1:3
    [c, lags] = xcorr(x(:,k));
    
    [pks,locs] = findpeaks(c,...
        'minpeakprominence',minprom,...
        'minpeakdistance',minpkdist);
    
    tc = (1/fs)*lags;
    tcl = tc(locs);
    
    % Feature 1 - peak height at 0
    if(~isempty(tcl))   % else f1 already 0
        feats(3*(k-1)+1) = pks((end+1)/2);
    end
    % Features 2 and 3 - position and height of first peak
    if(length(tcl) >= 3)   % else f2,f3 already 0
        feats(3*(k-1)+2) = tcl((end+1)/2+1);
        feats(3*(k-1)+3) = pks((end+1)/2+1);
    end
end
end

function feats = spectralPowerFeatures(x, fs)

edges = [0.5, 1.5, 5, 10, 15, 20, 25, 30];

[xpsd, f] = periodogram(x,[],4096,fs);

featstmp = zeros(7,3);

for kband = 1:length(edges)-1
    featstmp(kband,:) = sum(xpsd( (f>=edges(kband)) & (f<edges(kband+1)), :),1);
end
feats = featstmp(:);
end

clear; clc

datadir = '../../Dataset_Originale/';

%choose number of patients to examine (from 1 to 10)
for isubject = [1 2 3 8]
    
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
        Fs = 64;
        
        % filtro passa alto
        fhp = hpfilter;
        A = filter(fhp,A);
        
        size_windows_sec = 2;
        %size of the windows in number of samples
        size_windows_sample = Fs * size_windows_sec;
        
        %overlap of the windows in seconds
        size_overlap_sec = 1;
        %size of the overlap in number of samples
        size_overlap_samples = Fs * size_overlap_sec;
        
        number_sample = 1;
        
        %for each sample window, compute the features
        for i=1:size_overlap_samples:m - size_windows_sample
            B = A(i:i+size_windows_sample-1,:);
            [m,~] = size(B);
            
            % time sample
            F(number_sample, 1) = TIME(i,:);
%             % media
%             F(number_sample, 2:10) = mean(B);
%             % deviazione standard
%             F(number_sample, 11:19) = std(B);
%             % varianza
%             F(number_sample, 20:28) = std(B);
%             % energia
%             F(number_sample, 29:37) = energyn(B,Fs);
%             % potenza
%             F(number_sample, 38:46) = powern(B,Fs,m);
%             % freezing index
%             F(number_sample, 47) = freeze(B(:,1),Fs);
%             F(number_sample, 48) = freeze(B(:,2),Fs);
%             F(number_sample, 49) = freeze(B(:,3),Fs);
%             F(number_sample, 50) = freeze(B(:,4),Fs);
%             F(number_sample, 51) = freeze(B(:,5),Fs);
%             F(number_sample, 52) = freeze(B(:,6),Fs);
%             F(number_sample, 53) = freeze(B(:,7),Fs);
%             F(number_sample, 54) = freeze(B(:,8),Fs);
%             F(number_sample, 55) = freeze(B(:,9),Fs);
            % freezing index
            F(number_sample, 2) = freeze(B(:,1),Fs);
            F(number_sample, 3) = freeze(B(:,2),Fs);
            F(number_sample, 4) = freeze(B(:,3),Fs);
            F(number_sample, 5) = freeze(B(:,4),Fs);
            F(number_sample, 6) = freeze(B(:,5),Fs);
            F(number_sample, 7) = freeze(B(:,6),Fs);
            F(number_sample, 8) = freeze(B(:,7),Fs);
            F(number_sample, 9) = freeze(B(:,8),Fs);
            F(number_sample, 10) = freeze(B(:,9),Fs);
            %is freezing?
            F(number_sample,11) = mode(FREEZE(i:i+size_windows_sample-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
            
        end
        
        %% riduzione delle feature
%         mdl = fscnca(F(:,2:n-1),F(:,n));
% %         figure()
% %         plot(mdl.FeatureWeights,'ro')
% %         grid on
% %         xlabel('Feature index')
% %         ylabel('Feature weight')
%         F = [F(:,1) F(:,mdl.FeatureWeights > 0.001) F(:,n)];
%         
        %% salvo la tabella
        P = array2table(F);
        writetable(P, ['../../Features/2cl_feature_sec' num2str(size_windows_sec,2) '_ov' num2str(size_overlap_sec,2) '_' fileruns(r).name ]);
        display(['2cl_feature_sec' num2str(size_windows_sec,2) '_ov' num2str(size_overlap_sec,2) '_' fileruns(r).name]);
        F(:,:) = [];
    end
end

function energy = energyn(X,Fs)
energy = sum(X.^2)/Fs;
end

function power = powern(X,Fs,finestra)
power = energyn(X,Fs)/finestra;
end

function freezeIndex = freeze(X,Fs)
% power_walking = bandpower(X,Fs,[0.5 3]);
% power_freeze = bandpower(X,Fs,[3 8]);
% freezing_index = power_freeze/power_walking;

TH.freeze  =  [3 1.5 3 1.5 1.5 1.5 3 3 1.5 3];
TH.power   = 2.^ 12 ; %4096
NFFT = 256;
locoBand=[0.5 3];
freezeBand=[3 8];

f_res = Fs / NFFT;
f_nr_LBs  = round(locoBand(1)   / f_res);
f_nr_LBs( f_nr_LBs==0 ) = [];
f_nr_LBe  = round(locoBand(2)   / f_res);
f_nr_FBs  = round(freezeBand(1) / f_res);
f_nr_FBe  = round(freezeBand(2) / f_res);

% d = NFFT/2;

% [m,n] = size(X);
X = X - mean(X);

% Compute FFT
Y = fft(X);
Pyy = Y.* conj(Y) / Fs;

% --- calculate sumLocoFreeze and freezeIndex ---
areaLocoBand   = x_numericalIntegration( Pyy(f_nr_LBs:f_nr_LBe),Fs );
areaFreezeBand = x_numericalIntegration( Pyy(f_nr_FBs:f_nr_FBe),Fs );

sumLocoFreeze = areaFreezeBand + areaLocoBand;

freezeIndex = areaFreezeBand/areaLocoBand;
% --------------------

if sumLocoFreeze < TH.power
    freezeIndex = 0;
end
end

function i = x_numericalIntegration(x,SR)
i = (sum(x(2:end))/SR+sum(x(1:end-1))/SR)/2;
end

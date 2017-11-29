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
        A = table2array(T(:,2:10));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        B = [];
        
        %trasformazione dell'accelerazione da mg (milli-gravity) to m/s^2
        A = A / 1000 * 9.81;
        %tolgo il contributo della gravità sull'asse verticale
        for i = 2:3:8
           A(:,i) = A(:,i) - 9.81; 
        end
        number_sample = 1;
        indx = 0;
        end_size = 1;
        i = 1;
        Fs = 64;
        
        %filtro passa alto, rimuovo tutte i dati con frequenza minore di
        %0.5Hz
        [b,a] = butter(2,0.5/(Fs/2),'High');
        % freqz(b,a);
        A = filtfilt(b,a,A);
        %filtro passa basso, rimuovo tutti i dati con frequenza maggiore di
        %8Hz
        [b,a] = butter(10,8/(Fs/2),'Low');
        % freqz(b,a);
        A = filtfilt(b,a,A);      
        
        %decisione dell'intervallo della finestra massima
        number_seconds = 2;
        number_samples = Fs * number_seconds;
        %decisione dell'intervallo di sovrapposizione
        number_seconds2 = number_seconds / 2;
        number_samples2 = Fs * number_seconds2;
        
        %for each sample window, compute the features
        for i = 1:number_samples2:m-number_samples
            B = A(i:number_samples,:);
            [m1,n1] = size(B);
            
            % tempo campionamento
            F(number_sample,1) = TIME(i,:);
            % media
            F(number_sample,2:10) = mean(B);
            % media delle differenza tra X e Z
            F(number_sample,11) = mean(B(:,1)-B(:,2));
            F(number_sample,12) = mean(B(:,4)-B(:,6));
            F(number_sample,13) = mean(B(:,7)-B(:,9));
            % media delle differenze tra Y e X
            F(number_sample,14) = mean(B(:,2)-B(:,1));
            F(number_sample,15) = mean(B(:,5)-B(:,4));
            F(number_sample,16) = mean(B(:,8)-B(:,7));
            % differenza tra i valori medi dell'asse X in finestre
            % temporali consecutive
            if number_sample > 1
                F(number_sample,17) = F(number_sample,2) - F(number_sample-1,2);
                F(number_sample,18) = F(number_sample,5) - F(number_sample-1,5);
                F(number_sample,19) = F(number_sample,8) - F(number_sample-1,8);
            else
                F(number_sample,17) = F(number_sample,2);
                F(number_sample,18) = F(number_sample,5);
                F(number_sample,19) = F(number_sample,8);
            end
            % differenza tra i valori medi dell'asse Y e Z in finestre
            % temporali consecutive
            if number_sample > 1
                F(number_sample,20) = F(number_sample,3) - F(number_sample-1,4);
                F(number_sample,21) = F(number_sample,6) - F(number_sample-1,7);
                F(number_sample,22) = F(number_sample,9) - F(number_sample-1,10);
            else
                F(number_sample,20) = F(number_sample,3);
                F(number_sample,21) = F(number_sample,6);
                F(number_sample,22) = F(number_sample,9);
            end
            %differenza tra i valori medi dell'asse Z e X in finestre
            %temporali diverse
            if number_sample > 1
                F(number_sample,23) = F(number_sample,4) - F(number_sample-1,2);
                F(number_sample,24) = F(number_sample,7) - F(number_sample-1,5);
                F(number_sample,25) = F(number_sample,10) - F(number_sample-1,8);
            else
                F(number_sample,23) = F(number_sample,4);
                F(number_sample,24) = F(number_sample,7);
                F(number_sample,25) = F(number_sample,10);
            end
            % deviazione standard
            F(number_sample,26:34) = std(B);
            % correlation between axes
            %             F(number_sample,35) = eigs(cov(B(:,[1 2])),1);
            %             F(number_sample,36) = eigs(cov(B(:,[1 3])),1);
            %             F(number_sample,37) = eigs(cov(B(:,[2 3])),1);
            %             F(number_sample,38) = eigs(cov(B(:,[4 5])),1);
            %             F(number_sample,39) = eigs(cov(B(:,[4 6])),1);
            %             F(number_sample,40) = eigs(cov(B(:,[5 6])),1);
            %             F(number_sample,41) = eigs(cov(B(:,[7 8])),1);
            %             F(number_sample,42) = eigs(cov(B(:,[7 9])),1);
            %             F(number_sample,43) = eigs(cov(B(:,[8 9])),1);
            %             F(number_sample,35) = eigs(cov(B(:,1:3)),1);
            %             F(number_sample,36) = eigs(cov(B(:,4:6)),1);
            %             F(number_sample,37) = eigs(cov(B(:,7:9)),1);
            % skewness
            for z = 1:m1
               C(i,1) = norm(B(:,1:3));
               C(i,2) = norm(B(:,4:6));
               C(i,3) = norm(B(:,7:9));
            end
            F(number_sample,35:43) = skewness(B);
            F(number_sample,44:46) = skewness(C);
            % kurtosis
            F(number_sample,47:55) = kurtosis(B);
            F(number_sample,56:58) = kurtosis(C);
            % integrals = discrete summation
            F(number_sample,59:67) = sum(B);
            % auto-regression
            % F(number_sample,77:85) = arburg(B,4);          
            % is freezing?
            F(number_sample,68) = mode(FREEZE(i:end_size-1,:));
            
            %go to next sample
            number_sample = number_sample + 1;
        end
        
        P = array2table(F);
%       P.Properties.VariableNames = {'TIME_SAMPLE' 'MINACCX1' 'MINACCY1' 'MINACCZ1' 'MINACCX2' 'MINACCY2' 'MINACCZ2' 'MINACCX3' 'MINACCY3' 'MINACCZ3' 'MAXACCX1' 'MAXACCY1' 'MAXACCZ1' 'MAXACCX2' 'MAXACCY2', 'MAXACCZ2' 'MAXACCX3' 'MAXACCY3' 'MAXACCZ3' 'MEDIANACCX1' 'MEDIANACCY1' 'MEDIANACCZ1' 'MEDIANACCX2' 'MEDIANACCY2' 'MEDIANACCZ2' 'MEDIANACCX3' 'MEDIANACCY3' 'MEDIANACCZ3' 'MEANACCX1' 'MEANACCY1' 'MEANACCZ1' 'MEANCACCX2' 'MEANACCY2' 'MEANACCZ2' 'MEANACCX3' 'MEANACCY3' 'MEANACCZ3' 'ARMEMANX1' 'ARMMEANY1' 'ARMMEANZ1' 'ARMMEANX2' 'ARMMEANY2' 'ARMMEANZ2' 'ARMMEANX3' 'ARMMEANY3' 'ARMMEANZ3' 'RMSX1' 'RMSY1' 'RMSZ1' 'RMSX2' 'RMSY2' 'RMSZ2' 'RMSX3' 'RMSY3' 'RMSZ3' 'VARX1' 'VARY1' 'VARZ1' 'VARX2' 'VARY2' 'VARZ2' 'VARX3' 'VARY3' 'VARZ3' 'STDX1' 'STDY1' 'STDZ1' 'STDX2' 'STDY2' 'STDZ2' 'STDX3' 'STDY3' 'STDZ3' 'KURTX1' 'KURTY1' 'KURTZ1' 'KURTX2' 'KURTY2' 'KURTZ2' 'KURTX3' 'KURTY3' 'KURTZ3' 'SKEWX1' 'SKEWY1' 'SKEWZ1' 'SKEWX2' 'SKEWY2' 'SKEWZ2' 'SKEWX3' 'SKEWY3' 'SKEWZ3' 'MODEX1' 'MODEY1' 'MODEZ1' 'MODEX2' 'MODEY2' 'MODEZ2' 'MODEX3' 'MODEY3' 'MODEZ3' 'TRIMX1' 'TRIMY1' 'TRIMZ1' 'TRIMX2' 'TRIMY2' 'TRIMZ2' 'TRIMX3' 'TRIMY3' 'TRIMZ3' 'RANGEX1' 'RANGEY1' 'RANGEZ1' 'RANGEX2' 'RANGEY2' 'RANGEZ2' 'RANGEX3' 'RANGEY3' 'RANGEZ3' 'SMV1' 'SMV2' 'SMV3' 'SMA1' 'SMA2' 'SMA3' 'EVA1' 'EVA2' 'EVA3' 'AAE1' 'AAE2' 'AAE3' 'FREEZE'};
        writetable(P, [datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        display([datadir_feature '2cl_dynamics_' fileruns(r).name ]);
        F(:,:) = [];
        
    end
end

function svm = svmn(X, windows_length)
sum1 = norm(X);
svm = sum1 / windows_length;
end

function sma = sman(X, windows_length)
som = sum(abs(X(:,1))) + sum(abs(X(:,2))) + sum(abs(X(:,3)));
sma = som / windows_length;
end

function energy = energyn(X, windows_length)
%sum1 = sum(abs(X(:,1)).^2 + abs(X(:,2)).^2 + abs(X(:,3)).^2);
Fs = 64;
FT = fft(X);
pow = FT.*conj(FT) / Fs;
sum1 = sum(pow);
sum1 = sum(sum1,2);
energy = sum1 / windows_length;
end

function velocity = velocityn(X)
[m1,~] = size(X);
for i = 1:m1
    n(i,:) = norm(X(i,:));
end
velocity = trapz(n)/m1;
% Fs = 64;
% v = zeros(m1,3);
% C = zeros(m1,3);
% for i = 1:m1
%     C(i,1) = norm(A(i,1:3));
%     C(i,2) = norm(A(i,4:6));
%     C(i,3) = norm(A(i,7:9));
% end
% for i = 2:m1
%     v(i,:) = v(i-1,:) + (C(i,:)-C(i-1,:))*1/Fs;
% end
% velocity = mean(v);
end

function position = positionn(X)
[m1,~] = size(X);
for i = 1:m1
    n(i,:) = norm(X(i,:));
end
n = cumtrapz(n);
position = trapz(n);
% Fs = 64;
% s = zeros(m1,3);
% v = zeros(m1,3);
% C = zeros(m1,3);
% for i = 1:m1
%     C(i,1) = norm(A(i,1:3));
%     C(i,2) = norm(A(i,4:6));
%     C(i,3) = norm(A(i,7:9));
% end
% for i = 2:m1
%     v(i,:) = v(i-1,:) + (C(i,:)-C(i-1,:))*1/Fs;
% end
% for i = 2:m1
%     s(i,:) = s(i-1,:) + (v(i,:)-v(i-1,:))*1/Fs + 0.5*(C(i,:)-C(i-1,:))*(1/Fs).^2;
% end
% position = mean(s);
end

% function [FI, SLF] = freezingindex(X, SR, windows_length, isubject)
% TH.freeze  =  [3 1.5 3 1.5 1.5 1.5 3 3 1.5 3];
% TH.power   = 2.^ 12 ; %4096
% NFFT = 256;
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
% d = NFFT/2;
%
% [m,n] = size(X);
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
% if sumLocoFreeze < TH.power
%     freezeIndex = 0;
% end
%
% %          lframe = (freezeIndex>TH.freeze(isubject));
% FI = freezeIndex;
% SLF = sumLocoFreeze;
%
% end

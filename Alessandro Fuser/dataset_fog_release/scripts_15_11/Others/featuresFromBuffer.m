function feat = featuresFromBuffer(at, fs)
% featuresFromBuffer Extract vector of features from raw data buffer
% 
% Copyright 2014-2015 The MathWorks, Inc.

% Initialize digital filter
persistent fhp
if(isempty(fhp))
    fhp = hpfilter;
    fhp.PersistentMemory = false;
end

% Initialize feature vector
feat = zeros(1,60);

% Remove gravitational contributions with digital filter
ab = filter(fhp,at);

% Average value in signal buffer for all three acceleration components (1 each)
feat(1:3) = mean(at,1);

% RMS value in signal buffer for all three acceleration components (1 each)
feat(4:6) = rms(ab,1);

% Autocorrelation features for all three acceleration components (3 each): 
% height of main peak; height and position of second peak
feat(7:15) = autocorrFeatures(ab, fs);

% Spectral peak features (12 each): height and position of first 6 peaks
feat(16:51) = spectralPeaksFeatures(ab, fs);

% Spectral power features (5 each): total power in 5 adjacent
% and pre-defined frequency bands
feat(52:60) = spectralPowerFeatures(ab, fs);

% --- Helper functions
function feats = autocorrFeatures(x, fs)
n_channels = size(x,2);
feats = zeros(1,3*n_channels);

[c,lags] =arrayfun(@(i) xcorr(x(:,i)),1:n_channels,'UniformOutput',false);

minprom = 0.0005;
mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(1/fs));

% Separate peak analysis for all channels
for k = 1:n_channels
    [pks,locs] = findpeaks(c{k},...
        'minpeakprominence',minprom,...
        'minpeakdistance',minpkdist);
    
    tc = (1/fs)*lags{k};
    tcl = tc(locs);
    
    % Feature 1 - peak height at 0
    if(~isempty(tcl))   % else f1 already 0
        feats(n_channels*(k-1)+1) = pks((end+1)/2);
    end
    % Features 2 and 3 - position and height of first peak 
    if(length(tcl) >= 2)   % else f2,f3 already 0
        feats(n_channels*(k-1)+2) = tcl(2);
        feats(n_channels*(k-1)+3) = pks(2);
    end
end

function feats = spectralPeaksFeatures(x, fs)
n_channels = size(x,2);
mindist_xunits = 0.3;

feats = zeros(1,12*n_channels);

N = 4096;
minpkdist = floor(mindist_xunits/(fs/N));

% Cycle through number of channels
for k = 1:n_channels
    [p, f] = periodogram(x(:,k),rectwin(length(x)),4096,fs);
    [pks,locs] = findpeaks(p,'npeaks',20,'minpeakdistance',minpkdist);
    if(~isempty(pks))
        mx = min(6,length(pks));
        [spks, idx] = sort(pks,'descend');
        slocs = locs(idx);
        
        pks = spks(1:mx);
        locs = slocs(1:mx);
        
        [slocs, idx] = sort(locs,'ascend');
        spks = pks(idx);
        opks = spks;
        locs = slocs;
    end
    ofpk = f(locs);
    
    % Features 1-6 positions of highest 6 peaks
    feats(12*(k-1)+(1:length(opks))) = ofpk;
    
    % Features 7-12 power levels of highest 6 peaks
    feats(12*(k-1)+(7:7+length(opks)-1)) = opks;
end

function feats = spectralPowerFeatures(x, fs)
n_channels = size(x,2);

edges = [0.5, 1.5, 5, 10];
n_feats = length(edges)-1;
feats = zeros(1,n_feats*n_channels);

for k=1:n_channels
    [p, f] = periodogram(x(:,k),rectwin(length(x)),4096,fs);
    for kband = 1:n_feats
        feats(n_feats*(k-1)+kband) = sum(p( (f>=edges(kband)) & (f<edges(kband+1)) ));
    end
end

function feat = featuresFromBuffer_codegen(at, fs)
% featuresFromBuffer Extract vector of features from raw data buffer
% 
% Copyright 2014-2015 The MathWorks, Inc.

% Initialize digital filter
persistent dcblock corr spect f
if(isempty(dcblock))
    [s,g] = getFilterCoefficients(fs);
    dcblock = dsp.BiquadFilter('Structure','Direct form II transposed', ...
        'SOSMatrix',s,'ScaleValues',g);

    NFFT = 4096;
    spect = dsp.SpectrumEstimator('SpectralAverages',1,...
        'Window','Rectangular','FrequencyRange','onesided',...
        'SampleRate',fs,'SpectrumType','Power density',...
        'FFTLengthSource','Property','FFTLength',4096);
    f = (fs/NFFT)*(0:NFFT/2)';

    corr = dsp.Autocorrelator;
end

% Initialize feature vector
feat = zeros(1,60);

% Remove gravitational contributions with digital filter
ab = step(dcblock,at);

% Average value in signal buffer for all three acceleration components (1 each)
feat(1:3) = mean(at,1);

% RMS value in signal buffer for all three acceleration components (1 each)
feat(4:6) = rms(ab,1);

% Autocorrelation features for all three acceleration components (3 each): 
% height of main peak; height and position of second peak
feat(7:15) = autocorrFeatures(ab, corr, fs);

% Pre-compute spectra of 3 channels for frequency-domain features
af = step(spect,ab);

% Spectral peak features (12 per channel): value and freq of first 6 peaks
feat(16:51) = spectralPeaksFeatures(af, f);

% Spectral power features (3 each): total power in 3 adjacent
% and pre-defined frequency bands
feat(52:60) = spectralPowerFeatures(af, f);

% --- Helper functions
function feats = autocorrFeatures(x, corr, fs)
n_channels = size(x,2);
feats = zeros(1,3*n_channels);

c = step(corr, x);
lags = (0:length(x)-1)';

minprom = 0.0005;
mindist_xunits = 0.3;
minpkdist = floor(mindist_xunits/(1/fs));

% Separate peak analysis for all channels
for k = 1:n_channels
    [pks,locs] = findpeaks([0;c(:,k)],...
        'minpeakprominence',minprom,...
        'minpeakdistance',minpkdist);

    tc = (1/fs)*lags;
    tcl = tc(locs-1);

    % Feature 1 - peak height at 0
    feats(n_channels*(k-1)+1) = c(1,k);
    % Features 2 and 3 - position and height of first peak 
    if(length(tcl) >= 2)   % else f2,f3 already 0
        feats(n_channels*(k-1)+2) = tcl(2);
        feats(n_channels*(k-1)+3) = pks(2);
    end
end

function feats = spectralPeaksFeatures(xpsd, f)
n_channels = size(xpsd,2);
mindist_xunits = 0.3;

feats = zeros(1,12*n_channels);

minpkdist = floor(mindist_xunits/f(2));

% Cycle through number of channels
nfinalpeaks = 6;
for k = 1:n_channels
    [pks,locs] = findpeaks(xpsd(:,k),'npeaks',20,'minpeakdistance',minpkdist);
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

function feats = spectralPowerFeatures(xpsd, f)
n_channels = size(xpsd,2);

edges = [0.5, 1.5, 5, 10];
n_feats = length(edges)-1;

featstmp = zeros(n_feats,n_channels);
    
for kband = 1:length(edges)-1
    featstmp(kband,:) = sum(xpsd( (f>=edges(kband)) & (f<edges(kband+1)), : ),1);
end
feats = featstmp(:);

function [s,g] = getFilterCoefficients(fs)
coder.extrinsic('zp2sos')
[z,p,k] = ellip(7,0.1,60,0.4/(fs/2),'high');
[s,g] = coder.const(@zp2sos,z,p,k);
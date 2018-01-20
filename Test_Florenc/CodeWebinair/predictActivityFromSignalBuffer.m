function predictedActid = predictActivityFromSignalBuffer(at, fs, fmean, fstd)
% predictActivityFromSignalBuffer predicts an activity ID from the (Nx3)
% input acceleration buffer at. fs is teh sample frequency used for at,
% while fmean and fstd are teh pre-computed feature normalization
% parameters
% 
% Copyright 2015 The MathWorks, Inc.

% Extract feature vector
rawf = featuresFromBuffer(at, fs);
f = (rawf-fmean)./fstd;

% Classify with neural network
scores = mynn(f');  % or % scores = net(f');
% Interpret result: use index of maximum score to retrieve the name of
% the activity
[~, predictedActid] = max(scores);

end
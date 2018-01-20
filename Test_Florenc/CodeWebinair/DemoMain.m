%% Human Activity Classification based on Smartphone Sensor Signals
% 
% Copyright 2014-2015 The MathWorks, Inc.

%% Introduction
% This example describes an analysis approach on accelerometer signals
% captured with a smartphone. The smartphone is worn by a subject during 6
% different types of physical activity. 
% The goal of the analysis is to build an algorithm that automatically
% identifies the activity type given the sensor measurements. 
%
% The example uses data from a recorded dataset, courtesy of:
%  Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L.
%  Reyes-Ortiz. Human Activity Recognition on Smartphones using a
%  Multiclass Hardware-Friendly Support Vector Machine. International
%  Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz,
%  Spain. Dec 2012
%
% The original dataset is available from
% <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

%% Check data availability
% The data need to be prepared prior to running the code in the rest of
% this script.
% To prepare the data run the script DataPreparation.m first. That guides
% through the process of downloading the data and preparing it for this
% example.
% 
% At the end of the process, the folder .\Data\Prepared must contain
% the following four data files:
% 
% * BufferedAccelerations.mat
% * BufferFeatures.mat
% * RecordedAccelerationsBySubject.mat
% * TrainedNetwork.mat

% Check that the prepared data is available, and add the data folder to
% the MATLAB search path
if ~isAllPreparedDataAvailable
    disp('Some prepared data is not yet available. Please run DataPreparation.m first')
end

%% Objective of the example
% Let's take a look at what our final result may look like. This will give
% us a better feel for what we are trying to achieve.
% For the time being you do not need to understand how this is realized

runTrainedNetworkOnBufferedData

%% Open full "recording" for a single subject (e.g. #1)
% Let's look at the data. Given the data:
% 
% * We would like to be able to tell the difference between the different
%   activities, just based on the content of the signal. 
% * Note in this case the coloring is based on existing knowledge (actid)
% * Labeled data can be used to "train" a classification algorithm so it
%   can it later predict the class of new (unlabeled) data. 

% Use a custom function to retrieve a single acceleration component for a
% particular subject.
[acc, actid, actlabels, t, fs] = getRawAcceleration('SubjectID',1,...
    'Component','x');

% Visualize the same signal using a custom plotting function, which also
% uses the information in actid
plotAccelerationColouredByActivity(t, acc, actid, {'Vertical acceleration'})

%% First type of characterization - amplitude only
% Looking only at the raw values irrespective or their position is time can
% provide a first set of clues

%% First example - Using a mean measure
% This can easily help separate e.g. Walking from Laying
figure
plotCompareHistForActivities(acc, actid,'Walking', 'Laying')

%% Second example - Using an RMS or standard deviation measure
% This can help separate things like e.g. Walking and Standing
plotCompareHistForActivities(acc, actid,'Walking', 'Standing')

%% What next? Amplitude-only methods are often not enough
% For example it would be very hard to distinguish between
% simply Walking and WalkingUpstairs (very similar statistical moments)
% 
% An initial conclusion is that simple statistical analysis is often not
% sufficient. 
% For signals one should also consider methods that measure signal
% variations over time

plotCompareHistForActivities(acc, actid,'Walking', 'WalkingUpstairs')

%% Time-domain analysis - preliminary considerations
% There two main different types of causes behind our signals: 
% 
% * One to do with "fast" variations over time, due to body
%   dynamics (physical movements of the subject)
% * The other, responsible for "slow" variations over time, due to the
%   position of the body with respect to the vertical gravitational field
%
% As we focus on classifying the physical activities, we should focus
% time-domain analysis on the effects of body movements. These are 
% responsible for the most "rapid" (or frequent) variations in our signal.
% 
% In this specific case a simple average over a period of time would
% easily estimate the gravitational component, which could be then
% subtracted from the relevant samples to obtain the signal due to the
% physical movements.
% 
% For the sake of generality here we introduce an approach based on
% digital filters, which is much more general and can be reused in more
% challenging situations.

%% Digital filtering workflow
% To isolate the rapid signal variations from the slower ones using digital
% filtering:
% 
% * Design a high-pass filter (e.g. using the Filter Design and Analysis
%   Tool, fdatool, in MATLAB)
% * Apply the filter to the original signal

%% Filter out gravitational acceleration
% As well as interactively, filters can be designed programmatically. 
% In this case the function hpfilter was generated automatically from
% the Filter Design and Analysis Tool, but it could have just as well been
% created manually

% Design filter
fhp = hpfilter;

% "Decouple" acceleration due to body dynamics from gravity
ab = filter(fhp,acc);

% Compare the filtered signal with the original one
plotAccelerationColouredByActivity(t, [acc, ab], actid,...
    {'Original','High-pass filtered'})

%% Focus on a single activity first: select first portion of Walking signal
% Use logical indexing. In plain English, this is what we are trying to do:
% "Only select samples for which the activity was Walking and for which the
% time was less than 250 seconds"

% Assume we know the activity id for Walking is 1
walking = 1;
sel = (t < 250) & (actid == walking);

% Select only desired array segments for time vector
% and acceleration signal
tw = t(sel);
abw = ab(sel);

% Plot walking-only signal segment. Use interactive plot tools to zoom in
% and explore the signal. Note the quasi-periodic behavior.
figure
plotAccelerationColouredByActivity(tw, abw, [],'Walking')

%% Plot Power Spetral Density
% Use Welch method with its default options, using known sample frequency

% When called without output arguments, the function pwelch plots the PSD
figure
pwelch(abw,[],[],[],fs)

%% Validate potential of PSD to differentiate between different activities
% E.g. are position and height in the two respsctive sets of peaks
% different for different activities?

plotPSDActivityComparisonForSubject(1, 'Walking', 'WalkingUpstairs')

%% Automate peak identification
% The function findpeaks in Signal Processing Toolbox can be used to
% identify amplitude and location of spectral peaks

% Compute numerical values of PSD and frequency vector. When called with
% one or two output arguments, the function pwelch does not automatically
% plot the PSD
[p,f] = pwelch(abw,[],[],[],fs);

% Use findpeaks to identify values (amplitude) and index locations of peaks
[pks,locs] = findpeaks(p);

% Plot PSD manually and overlay peaks
plot(f,db(p),'.-')
grid on
hold on
plot(f(locs),db(pks),'rs')
hold off
addActivityLegend(1)
title('Power Spectral Density with Peaks Estimates')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%% Refine peak finding by adding more specific requirements

% PSD with numerical output
[p,f] = pwelch(abw,[],[],[],fs);

% Find max 8 peaks, at least 0.25Hz apart from each other and with a given
% prominence value

fmindist = 0.25;                    % Minimum distance in Hz
N = 2*(length(f)-1);                % Number of FFT points
minpkdist = floor(fmindist/(fs/N)); % Minimum number of frequency bins

[pks,locs] = findpeaks(p,'npeaks',8,'minpeakdistance',minpkdist,...
    'minpeakprominence', 0.15);

% Plot PSD and overlay peaks
plot(f,db(p),'.-')
grid on
hold on
plot(f(locs),db(pks),'rs')
hold off
addActivityLegend(1)
title('Power Spectral Density with Peaks Estimates')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%% Feature summary
% After exploring interactively a few different techniques to extract
% descriptive features from this type of signals, we can collect
% all the analysis methods identified into a single function.
% The responsibility of this function is to extract a fixed number
% of features for each signal buffer provided as input.

featureExtractionFcn = 'extractSignalFeatures';

edit(featureExtractionFcn)

%% Count number of actual code lines of function featuresFromBuffer.m
% Using MATLAB Central submission "sloc" by Raymond Norris, available at
% <http://www.mathworks.co.uk/matlabcentral/fileexchange/3900-sloc>

count = sloc(featureExtractionFcn);

fprintf('\n%d lines of source code found in %s.m\n', ...
    count, featureExtractionFcn);

%% Prepare data to train classifier
% To train a classifier:
% 
% * Re-organise the acceleration signals into shorter buffers of fixed
%   length L, each labeled with a single activity ID
% * Extract a vector of features for each Lx3 signal buffer [ax, ay, az]
%   using the function featuresFromBuffer 
% * Provide an activity ID (a "label") for each feature vector, used to
%   train or test the classifier
% 
% To re-compute all features use the function extractAllFeatures, which
% 
% * Reads the buffered signals from BufferedAccelerations.mat
% * Computes a feature vector for each buffer using featuresFromBuffer
% * Saves all feature vectors into the file BufferFeatures.mat
% 
% Computing the features is a fairly efficient process, but it takes a
% while in this case because of the high number of signal vectors
% available.
% extractAllFeatures can distribute the computations to a pool of workers
% if Parallel Computing Toolbox is installed
% 
% If you have Parallel Computing Toolbox and a valid parallel pool
% available, try running extractAllFeatures twice, as follows:
% 
% * First run it as it is, and note the time taken to complete
% * Then change "for" to "parfor", open a parallel pool by executing
%   >> gcp in the command window, and finally run extractAllFeatures again.
%   This time the execution will be faster, with a gain in execution
%   speed dependent on the size of the parallel pool available.
% 
% For more details refer to the documentation of Parallel Computing Toolbox

clear all  %#ok<CLALL>

edit extractAllFeatures

%% Use pre-computed feature dataset
% A pre-computed set of feature vectors for all available signal buffers
% is available in the file BufferFeatures.mat

% Clear nonrelevant variables
clear all %#ok<CLALL>

% Load:
% * Pre-computed feature vectors (feat) and labels (actid, subid)
% * Feature names (featlabels)
% * Feature normalization parameters (fmean, fstd)
load('BufferFeatures.mat')

% Use the numerical data to create a MATLAB table (useful to quickly train
featTable = featuresTable(feat, featlabels, actid);

%% Identify a suitable classifier interactively
% The Statistics and Machine Learning Toolbox provides a long list of
% algorithms for classifiaction. The accelerate choosing the right
% classifier use the new Classification Learner App

classificationLearner

%% Train a Support Vector Machine (SVM) classifier
% Use a MATLAB function that was auto-generated by the Classification
% Learner App to train a classifiar based on the dataset.
% The returned arguments include information of how the dataset was
% partition during the training phase - so the remaining samples of the
% dataset can be used for testing the accuracy of the classifier.

% Train the classifier
[trainedClassifier, accuracy, cvp] = trainSVMClassifier(featTable);

% %% Test it programmatically
% 
% % For testing, only use the partion of the dataset that was not used for
% % trainig
% featTest = feat(cvp.test,:);
% actidTest = actid(cvp.test,:);
% 
% % Run the classifier of the test partion of the dataset
% predictedActid = predict(trainedClassifier, featTest);
% 
% % Visualize the prediction results as a confusion matrix
% figure
% plotconfusion(dummyvar(actidTest)',dummyvar(predictedActid)')

%% A possible alternative approach: train a neural network
% In this section we create, train and test neural network programmatically
% using Neural Network Toolbox. The Neural Network Toolbox also provides a
% number of interactive Apps to create, train and test neural networks. 
% For example for pattern recognition and classification refer to
% >> nprtool

% Reset random number generators
rng default

% Initialize a Neural Network with 18 nodes in hidden layer
% (assume the choice of the number 18 here is arbitrary)
net = patternnet(18);

% Use same training partition of the dataset used previously
featTest = feat(cvp.test,:);
actidTest = actid(cvp.test,:);
featTrain = feat(cvp.training,:);
actidTrain = actid(cvp.training,:);

% Train network
% For details about customizing the training function refer to the
% following:
% web(fullfile(docroot, 'nnet/ug/choose-a-multilayer-neural-network-training-function.html'))
net = train(net, featTrain', dummyvar(actidTrain)');

%%
% Predict activity ID from test portion of dataset
predActidNN = net(featTest');

% Display accuracy of results as confusion matrix
figure
plotconfusion(dummyvar(actidTest)',predActidNN)

%% Generate pre-trained prediction network
% A trained network can also be shared as an efficient and lightweight
% MATLAB function, which only uses basic matrix operations.
% In this form it will also be possible to generate source C/C++ code
% directly from the MATLAB code (MATLAB Coder required)

genFunction(net,'mynn.m','MatrixOnly','yes')

%% Compare exploratory feature extraction function with DSP system model

edit extractSignalFeatures featuresfromBuffer

%% Run Neural Network on buffered data
% We have now completed all the algorithmic steps necessary to implement
% the classification system presented at the very beginning of this
% example.

runTrainedNetworkOnBufferedData

% Inspecting runTrainedNetworkOnBufferedData will also highlight additional
% modelling and simulation steps related to handling streaming data
edit runTrainedNetworkOnBufferedData

%% Generate code from predictActivityFromSignalBuffer
% Once feature extraction and the neural network classifier are
% coded for streamed processing, MATLAB Coder can be used to automatically
% generate source C/C++, which can be also deployed to an embedded
% architecture

codegen predictActivityFromSignalBuffer -config:lib -c -args {randn(128,3), 50, zeros(1,66), zeros(1,66)} -launchreport

clc; clear;
leaveout_LDA_KNN2;
[trainedClassifier, validationAccuracy] = svm(PR);
LDA_KNN2;
yfit = trainedClassifier.predictFcn(Y');
confusionmat(yfit, class')
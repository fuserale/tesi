%% carica tabella di allenamento ed allena il classificatore
T = readtable('../../dataset/2cl_dynamics_3cl_S02R01.csv');
TM = table2array(T);
TM = [TM(:,1) zscore(TM(:,2:46)) TM(:,47)];
T = array2table(TM);
[trainedClassifier, validationAccuracy] = SvmClassifier(T);

%% carica tabella di test
T = readtable('../../dataset/2cl_dynamics_3cl_S01R01.csv');
TM = table2array(T);
TM = [TM(:,1) zscore(TM(:,2:46)) TM(:,47)];
T = array2table(TM);
yfit = trainedClassifier.predictFcn(T);

%% confronta i dati del classificatore con quelli reali
M = [yfit TM(:,47)];
C = confusionmat(yfit,TM(:,47))
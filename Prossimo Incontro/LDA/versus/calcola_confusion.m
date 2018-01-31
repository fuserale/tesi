clc; clear;

datadir = 'Schiena/';

M = [];

for isubject = [1 2 3 5 6 7 8 9]
    fileruns = dir([datadir 'versus_S' num2str(isubject,'%02d') '*.csv']);
    for r = 1:length(fileruns)
        filename = [datadir fileruns(r).name];
        T = readtable(filename);
        A = table2array(T);
        C = confusionmat(A(:,2),A(:,1));
%         tf = isdiag(C);
%         massimo = max(C);
%         [C,T,D]=multic(A(:,2),A(:,1));
%         B = [D(1) D(2) D(7) D(11) D(16)];
        M = [M C];
    end
end
writetable(array2table(M),[datadir 'confusion_matrix.csv']);
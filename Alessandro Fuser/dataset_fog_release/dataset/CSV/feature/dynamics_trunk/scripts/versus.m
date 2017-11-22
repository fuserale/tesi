clear; clc

most_long = [];

datadir = ['../dataset/CSV/feature/interval_2cl/S01R01/overlap_05/'];

datadir2 = ['../dataset/CSV/feature/interval_3cl/S01R01/overlap_05/'];


%list of all files for patient number $isubject
fileruns = dir([datadir '2cl_feature_sec.csv']);
alg = 'kmeans_cosine';

fileruns2 = dir([datadir alg '_2cl_*.csv']);

fileruns3 = dir([datadir2 '3cl_feature_sec*.csv']);

%while there's file of patient $isubject
for r = 1:length(fileruns)
    
    %name of the file
    filename = [datadir fileruns(r).name];
    %read table given in input
    T1 = readtable(filename);
    [m1,n1] = size(T1);
    A1 = table2array(T1(:,140));
    
    %name of the file
    filename2 = [datadir fileruns2(r).name];
    %read table given in input
    T2 = readtable(filename2);
    [m2,n2] = size(T2);
    A2 = table2array(T2(:,1));
    
    filename3 = [datadir2 fileruns3(r).name];
    T3 = readtable(filename3);
    A3 = table2array(T3(:,140));
    
    D = [A2 A1];
    
    
    for i=1:m1
        if D(i,1) ~= D(i,2)
            if D(i,1) == 1
                D(i,1) = 3;
            end
            if D(i,1) == 2
                D(i,1) = 4;
            end
        end
    end
    
    numb = 0;
    tot = 0;
    for i = 1:m1
        if ((D(i,1) == 3 || D(i,1) == 4))
            tot = tot + 1;
            if A3(i,1) == 3
                numb = numb + 1;
            end
        end
    end
    
end
function cancel_prefog

datadir = '../../dataset/';
datadir2 = '../../dataset/';
fileruns = dir([datadir2 '*.csv']);
for r = 1:length(fileruns)
    T = readtable([datadir2 fileruns(r).name]);
    A = table2array(T);
    T = array2table(A);
    writetable(T, [datadir fileruns(r).name]);
    display([datadir fileruns(r).name]);
end
end
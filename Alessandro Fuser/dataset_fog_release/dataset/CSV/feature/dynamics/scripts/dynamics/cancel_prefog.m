function cancel_prefog

datadir = '../../dataset/CSV/';
datadir2 = '../../dataset/CSV/original/';
fileruns = dir([datadir2 '*.csv']);
for r = 1:length(fileruns)
    T = readtable([datadir2 fileruns(r).name]);
    A = table2array(T);
    T = array2table(A);
    writetable(T, [datadir '2cl_' fileruns(r).name]);
    display([datadir '2cl_' fileruns(r).name]);
end
end
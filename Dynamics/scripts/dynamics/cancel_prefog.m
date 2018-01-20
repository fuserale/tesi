function cancel_prefog

datadir = '../../';
fileruns = dir([datadir '3cl_*.csv']);
for r = 1:length(fileruns)
    T = readtable([datadir fileruns(r).name]);
    A = table2array(T);
    [m,~] = size(T);
    for i = 1:m
       if (A(i,11) == 3)
           A(i,11) = 1;
       end
    end
    T = array2table(A);
    writetable(T, [datadir fileruns(r).name]);
    display([datadir fileruns(r).name]);
end
end
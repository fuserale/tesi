function extract_prefog

datadir = '../../dataset/CSV/';
datadir2 = '../../dataset/CSV/original/';
fileruns = dir([datadir2 '*.csv']);
for r = 1:length(fileruns)
    T = readtable([datadir2 fileruns(r).name]);
    
    [m,~] = size(T);
    A = table2array(T);
    size_windows_sec = 2;
    %size of the windows in number of samples
    size_windows_sample = round((size_windows_sec*1000)/15);
    
    
    for i = 1:m
        %disp(T.Var11);
        if A(i,11) == 2
            for l = i-(size_windows_sample+1):i-1
                if A(l,11) ~= 2
                    A(l,11) = 3;
                end
            end
            
            while (A(i,11) == 2 && i < m )
                i = i + 1;
            end
        end
        i = i + 1;
    end
    T = array2table(A);
    writetable(T, [datadir '3cl_' fileruns(r).name]);
end
end
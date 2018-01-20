function extract_prefog(u)

datadir2 = '../../';
fileruns = dir([datadir2 '3cl_*.csv']);
for r = 1:length(fileruns)
    T = readtable([datadir2 fileruns(r).name]);
    
    [m,~] = size(T);
    A = table2array(T);
    Fs = 64;
    size_windows_sec = u;
    %size of the windows in number of samples
    size_windows_sample = Fs * size_windows_sec;
    
    i = 1;
    while i < m
        %disp(T.Var11);
        if A(i,11) == 2
            for l = i-(size_windows_sample):i-1
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
    writetable(T, [datadir2 fileruns(r).name]);
    display([datadir2 fileruns(r).name]);
end
end
T = readtable('3cl_S01R01.csv');
A = table2array(T);
Fs = 64;
for i=1:64*2:92802 
    if mode(A(i:i+128,11) == 1)
        plot(A(i:i+128,1),A(i:i+128,8));
        xlabel('NOFOG');
    end
    if mode(A(i:i+128,11) == 2)
        plot(A(i:i+128,1),A(i:i+128,8));
        xlabel('FOG');
    end
    if mode(A(i:i+128,11) == 3)
        plot(A(i:i+128,1),A(i:i+128,8));
        xlabel('PREFOG');
    end

end
% 
% NOFOG = A(A(:,11)==1,:);
% FOG = A(A(:,11)==2,:);
% PREFOG = A(A(:,11)==3,:);
% sample = 1;
% 
% for i = 1:128:length(NOFOG)-128
%     nofog_mean(sample,:) = mean(NOFOG(i:i+128,2:10));
%     nofog_median(sample,:) = median(NOFOG(i:i+128,2:10));
%     nofog_std(sample,:) = std(NOFOG(i:i+128,2:10));
%     sample = sample+1;
% end
% 
% fog_mean = mean(FOG(:,2:10));
% fog_median = median(FOG(:,2:10));
% fog_std = std(FOG(:,2:10));
% 
% prefog_mean = mean(PREFOG(:,2:10));
% prefog_median = median(PREFOG(:,2:10));
% prefog_std = std(PREFOG(:,2:10));
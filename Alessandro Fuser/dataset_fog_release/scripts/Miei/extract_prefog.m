function prefog

    datadir = '../../dataset/CSV/';
    fileruns = dir([datadir '*.csv']);
    for r = 1:length(fileruns)
    T = readtable([datadir fileruns(r).name]);

    [m,n] = size(T);
    F = T(1,:);
    i = 1;

    while i < (m-133)
        %disp(T.Var11);
        if T.FR(i) == 2
            %disp('Trovato');
             F(end+1:end+133,:) = T(i-133:i-1, :);
            
            %figure; plot(T.Var2(i-15:i-1, :));
            
%                 figure; 
%                 subplot(3,1,1);
%                 x = T.TIME(i-133:i-1, :);
%                 y1 = T.ACCX1(i-133:i-1, :);
%                 plot(x,y1);
%                 title('AccX');
% 
%                 subplot(3,1,2);
%                 y2 = T.ACCY1(i-133:i-1, :);
%                 plot(x, y2);
%                 title('AccY');
% 
%                 subplot(3,1,3);
%                 y3 = T.ACCZ1(i-133:i-1, :);
%                 plot(x, y3);
%                 title('AccZ');
    
            while (T.FR(i) == 2 )
                i = i + 1;
            end
        end
        i = i + 1;
    end
   
%     f = figure();
%     subplot(3,1,1);
%     x = F.Var1;
%     y1 = F.Var2;
%     plot(x,y1);
%     title('AccX');
%     
%     subplot(3,1,2);
%     y2 = F.Var3;
%     plot(x, y2);
%     title('AccY');
%     
%     subplot(3,1,3);
%     y3 = F.Var4;
%     plot(x, y3);
%     title('AccZ');
    
    F(1,:)=[];
    writetable(F,['../../dataset/CSV/prefog/' strcat('prefog_',fileruns(r).name)]);
    end
end
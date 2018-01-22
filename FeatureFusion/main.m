clc;
clear;
close all;

%% Load Data
datadir = 'dataset_2cl/';
%T = readtable('3cl_S01R01.csv');
x = 01;
T = readtable([datadir '2cl_leaveout_' num2str(x, '%01d') '.csv']);
[m,n] = size(T);
A = table2array(T(:,2:10));
TIME = table2array(T(:,1));
FREEZE = table2array(T(:,11));
Fs = 64;

%% Lunghezza della finestra
size_windows_sec = 2;
size_windows_sample = Fs * size_windows_sec;
%% Lunghezza dell'overlap (deve essere minore della finestra)
size_overlap_sec = 1;
size_overlap_samples = Fs * size_overlap_sec;

number_sample = 1;
%% Linearizza i dati degli accelerometri, ossia per ogni finestra metti le colonne in un vettore
% Es. con 2 secondi: 128*9=1152
for i=1:size_overlap_samples:m - size_windows_sample
    B = A(i:i+size_windows_sample-1,:);
    [m,~] = size(B);
    
    F(number_sample, :) = B(:);
    class(number_sample) = mode(FREEZE(i:i+size_windows_sample-1,:));
    
    number_sample = number_sample + 1;
    
end
% C = [F,class'];

% %% Codice LDA_KNN2
% %
% % FREEZE
% % 1 non fog
% % 2 fog
% % 3 prefog
% 
% 
% % perchè in A ho i dati cosi ogni colonna corrisponde ad un accelerometro, li prendo tutti
% clear A;
% A=F';
% 
% %quindi ho A 1152x1449 double: 1152 finestre ed ogni finestra ha 1449 features
% [d,N] = size(A);
% 
% K =  max(class); % numero classi in gioco;
% 
% % 1. determino le classi Ck
% for k = 1:K
%     a = find (class== k);
%     Ck{k} = A(:, a);   
% end
% 
% % 2. determino le medie
% for k = 1:K
%     mk{k} = mean(Ck{k},2);
% end
% % 3. determino la numerosità della classe
% for k = 1:K
%     [d, Nk(k)] = size(Ck{k});
% end
% % 4. determino le within class covariance
% for k = 1:K
%     S{k} = 0;
%     for i = 1:Nk(k)
%         S{k} = S{k} + (Ck{k}(:,i)-mk{k})*(Ck{k}(:,i)-mk{k})';
%     end
%     S{k} = S{k}./Nk(k);
% end
% Swx = 0;
% for k = 1:K
%     Swx = Swx + S{k};
% end
% 
% % 5. determino la between class covariance
% % 5.1 determino la media totale
% m = mean(A,2);
% Sbx = 0;
% for k=1:K
%     Sbx = Sbx + Nk(k)*((mk{k} - m)*(mk{k} - m)');
% end
% Sbx = Sbx/K;
% 
% MA = inv(Swx)*Sbx;
% 
% % eigenvalues/eigenvectors
% [V,D] = eig(MA);
% 
% % 5: transform matrix
% W = V(:,1:2);
% 
% % 6: transformation
% Y = W'*A;
% 
% % 7: plot
% figure, gscatter(Y(1,:),Y(2,:),class)
% legend('NoFog','Fog')
% % legend('NoFog','Fog','PreFog')

%% Default linear discriminant analysis (LDA)
lda = fitcdiscr(F,class');
ldaClass = resubPredict(lda);
ldaResubErr = resubLoss(lda)
[ldaResubCM,grpOrder] = confusionmat(class',ldaClass)
% figure, gscatter(lda.Mu(1,:), lda.Mu(2,:), class');
% legend('NoFog','Fog');

%% Predizione su altri dati
F = [];
T2 = readtable([datadir 'S' num2str(x, '%02d') 'R01.csv']);
[m,n] = size(T2);
A2 = table2array(T2(:,2:10));
TIME2 = table2array(T2(:,1));
FREEZE2 = table2array(T2(:,11));
Fs = 64;
number_sample = 1;
for i=1:size_overlap_samples:m - size_windows_sample
    B2 = A2(i:i+size_windows_sample-1,:);
    [m,~] = size(B2);
    
    F2(number_sample, :) = B2(:);
    class2(number_sample) = mode(FREEZE2(i:i+size_windows_sample-1,:));
    
    number_sample = number_sample + 1;
    
end

label = predict(lda, F2);
[ldaResubCM,grpOrder] = confusionmat(class2',label)

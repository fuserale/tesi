%  LDA 

%2� prova uso i range


clear all
%close all

%carico il dato

%ho messo un run solo

datadir = '';

%choose number of patients to examine (from 1 to 10)
for isubject = [1]
    
    %list of all files for patient number $isubject
    fileruns = dir([datadir '3cl_S' num2str(isubject,'%02d') 'R01.csv']);
    
    %while there's file of patient $isubject
    for r = 1:length(fileruns)
        
        %name of the file
        filename = [datadir fileruns(r).name];
        %read table given in input
        T = readtable(filename); %csvread
        %take the dimesion
        [m,n] = size(T);
        %table to array to do maths
        A = table2array(T(:,2:10));
        TIME = table2array(T(:,1));
        FREEZE = table2array(T(:,11));
        Fs = 64;

        Y=1;  % overlap di 1 secondo (multiplo del periodo di campoionamento)
        i=2;  %dimensione della finestra
        
        
        %% RANGE..popolo F, vettore di range
                        size_windows_sec = i;
                %size of the windows in number of samples
                size_windows_sample = Fs * size_windows_sec;
                
                %overlap of the windows in seconds
                size_overlap_sec = Y;
                %size of the overlap in number of samples
                size_overlap_samples = Fs * Y;
                
                number_sample = 1;
                
                %for each sample window, compute the features

%metto tutta la finestra (matrice 128*9) sulla stessa riga
for i=1:size_overlap_samples:m - size_windows_sample
                    B = A(i:i+size_windows_sample-1,:); %B � 128 * 9 (2 secondi)
                    B=B(:);
                    F(number_sample,:)=B';
                 
                    
                    %salvo la classe di ogni finestra
                    class(number_sample)=mode(FREEZE(i:i+size_windows_sample-1,:));
                    
                    %go to next sample
                    number_sample = number_sample + 1;
                    
                end
                
                
               % P = array2table(F);

        
    end
end
%%




% 
% FREEZE
% 1 non fog 
% 2 fog
% 3 prefog


    % perch� in A ho i dati cosi
    % ogni colonna corrisponde 
    % ad un accelerometro, li prendo tutti
%     A=A';
clear A;
A=F';

%quindi ho A 1152x1449 double
%1152 finestre 
%ogni finestra ha 1449 features
    [d,N] = size(A);

K =  max(class); % numero classi in gioco;

% 1. determino le classi Ck
for k = 1:K
    a = find (class== k);
    Ck{k} = A(:, a);

end

% 2. determino le medie
for k = 1:K
    mk{k} = mean(Ck{k},2);
end
% 3. determino la numerosit� della classe
for k = 1:K
    [d, Nk(k)] = size(Ck{k});
end
% 4. determino le within class covariance
for k = 1:K
    S{k} = 0;
    for i = 1:Nk(k)
        S{k} = S{k} + (Ck{k}(:,i)-mk{k})*(Ck{k}(:,i)-mk{k})';
    end
    S{k} = S{k}./Nk(k);
end
Swx = 0;
for k = 1:K
    Swx = Swx + S{k};
end

% 5. determino la between class covariance
% 5.1 determino la media totale
m = mean(A,2);
Sbx = 0;
for k=1:K
    Sbx = Sbx + Nk(k)*((mk{k} - m)*(mk{k} - m)');
end
Sbx = Sbx/K;

MA = inv(Swx)*Sbx;

% eigenvalues/eigenvectors
[V,D] = eig(MA);

% 5: transform matrix
W = V(:,1:2);

% 6: transformation
Y = W'*A;

% 7: plot
figure, scatter(Y(1,:),Y(2,:),[],class);
legend('C1','C2','C3')




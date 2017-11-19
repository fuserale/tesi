%Nodo discreto (1): situazione
%Nodo continuo (2): valori continui misurati, nodo multivariato
%HMM con osservazioni gaussiane
%   1 - > 1
%   |     | 
%   v     v
%   2     2  

O = 4;
T = 3601;
ncases = 1;
data = zeros(O,T,ncases);

M = 1; %numero di componenti della mistura di gaussiane
Q = 2; %la variabile hidden ha due stati

%Caricamento data set
data2h = dataset('file', 'ESP2_h', 'delimiter', '\t'); %mio data9 più corto
data4h = dataset('file', 'ESP4_h', 'delimiter', '\t'); %mio data5 più lungo
data5h = dataset('file', 'ESP5_h', 'delimiter', '\t'); %mio data7 più corto

data1 = dataset('file', 'output1.out', 'delimiter', '\t');
data2 = dataset('file', 'output2.out', 'delimiter', '\t');
data3 = dataset('file', 'output3.out', 'delimiter', '\t');
data4 = dataset('file', 'output4.out', 'delimiter', '\t');
data5 = dataset('file', 'output5.out', 'delimiter', '\t');
data6 = dataset('file', 'output6.out', 'delimiter', '\t');
data7 = dataset('file', 'output7.out', 'delimiter', '\t');
data8 = dataset('file', 'output8.out', 'delimiter', '\t');
data9 = dataset('file', 'output9.out', 'delimiter', '\t');

%Solo variabili: EC, DO, TEMP, VOLT
data2h = data2h(1:end,[4:7]);
data4h = data4h(1:end,[4:7]);
data5h = data5h(1:3601,[4:7]);

data1 = data1(1:end,[3:6]);
data2 = data2(1:end,[3:6]);
data3 = data3(1:end,[3:6]);
data4 = data4(1:end,[3:6]);
data5 = data5(1:end,[3:6]);
data6 = data6(1:end,[3:6]);
data7 = data7(1:end,[3:6]);
data8 = data8(1:end,[3:6]);
data9 = data9(1:end,[3:6]);

%converto il data-set in una matrice
data2hmat = double(data2h);
data4hmat = double(data4h);
data5hmat = double(data5h);

data1mat = double(data1);
data2mat = double(data2);
data3mat = double(data3);
data4mat = double(data4);
data5mat = double(data5);
data6mat = double(data6);
data7mat = double(data7);
data8mat = double(data8);
data9mat = double(data9);

%data(:,:,1) = double(data2mat');
data(:,:,1) = double(data5hmat');

%probabilità a priori delle situazioni (random)
prior0 = normalise(rand(Q,1)); 

for i=1:Q
prior0(i) = 1/Q;
end

%probabilità di passare dallo stato A al tempo i allo stato B al tempo i+1
transmat0 = mk_stochastic(rand(Q,Q));  

% for i=1:Q
%     for j=1:Q
%     transmat0(i,j) = 0.01;
%         if(i==j)
%          transmat0(i,j) = 1-(Q-1)/100;
%         end
%     end
% end

% %observation model
%          Sigma0 = repmat(eye(O), [1 1 Q M]); %standard deviation %matrice a covarianza diagonale
%          %Initialize each mean to a random data point
%          indices = randperm(ncases);
%          mu0 = reshape(data(:,indices(1:(Q*M))), [O Q M]); %media
%          mixmat0 = mk_stochastic(rand(Q,M)); %mixmat contiene il peso di ogni componente dato quello stato
        
cov_type = 'full'; %VERIFICARE SE VALUE CORRETTO
[mu0, Sigma0] = mixgauss_init(Q*M, reshape(data, [O T*ncases]), cov_type);
mu0 = reshape(mu0, [O Q M]);
Sigma0 = reshape(Sigma0, [O O Q M]);
mixmat0 = mk_stochastic(rand(Q,M));

for i=1:Q
mixmat0(i) = 1/Q;
end

max_iter = 10;

%Finally, let us improve these parameter estimates using EM.
[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', max_iter);
%Since EM only finds a local optimum, good initialisation is crucial.
%The initialisation procedure illustrated above is very crude,
%and is probably not adequate for real applications... Click here
%for a real-world example of EM with mixtures of Gaussians using BNT.

%use the following procedure to compute likelihood:
loglik = mhmm_logprob(data, prior1, transmat1, mu1, Sigma1, mixmat1);


%First you need to evaluate B(t,i) = P(y_t | Q_t=i) for all t,i:
B = mixgauss_prob(data, mu1, Sigma1, mixmat1);
%where data(:,:,ex) is OxT where O is the size of the observation vector. Finally, use
[path] = viterbi_path(prior1, transmat1, B);

risultato = [path',data'];

% risultato2 = risultato;
% risultato2(:,2) = risultato2(:,2)/100;
% 
% figure(1)
% plot(risultato2);
% 
% figure(3)
% subplot(4,1,1);
% plot(risultato(:,2));ylabel('EC');
% subplot(4,1,2);
% plot(risultato(:,3));ylabel('TEMP');
% subplot(4,1,3);
% plot(risultato(:,4));ylabel('DO');
% subplot(4,1,4);
% plot(risultato(:,5));ylabel('VOLT');xlabel('TIME');

figure(2)
subplot(5,1,1);
plot(risultato(:,1));ylabel('SIT');
subplot(5,1,2);
plot(risultato(:,2));ylabel('EC');
subplot(5,1,3);
plot(risultato(:,3));ylabel('TEMP');
subplot(5,1,4);
plot(risultato(:,4));ylabel('DO');
subplot(5,1,5);
plot(risultato(:,5));ylabel('VOLT');xlabel('TIME');



trasf = zeros(length(data4hmat'),33);

Sigmanew= mu1;

for i=1:Q
    for j=1:O
    Sigmanew(j,i)=Sigma1(j,j,i);
    end
end


for i=1:length(trasf)
    %numero di situazione (fino a 10 max)
    for j=1:10
        if(risultato(i,1)==j)
            trasf(i,j) = 1;
        end
    end      
    %EC_0
    if(risultato(i,2)==0)
        trasf(i,11) = 1;
    end
    %EC_1
    if(risultato(i,2) >= 1 && risultato(i,2) < 500)
        trasf(i,12) = 1;
    end
    %EC_2
    if(risultato(i,2) >= 500 && risultato(i,2) < 1000)
        trasf(i,13) = 1;
    end
    %EC_3
    if(risultato(i,2) >= 1000 && risultato(i,2) < 1500)
        trasf(i,14) = 1;
    end
    %EC_4
    if(risultato(i,2) >= 1500)
        trasf(i,15) = 1;
    end
    %TEMP_0
    if(risultato(i,3) < 12)
        trasf(i,16) = 1;
    end 
    %TEMP_1
    if(risultato(i,3) >= 12 && risultato(i,3) < 14)
        trasf(i,17) = 1;
    end 
    %TEMP_2
    if(risultato(i,3) >= 14 && risultato(i,3) < 16)
        trasf(i,18) = 1;
    end 
    %TEMP_3
    if(risultato(i,3) >= 16 && risultato(i,3) < 18)
        trasf(i,19) = 1;
    end 
    %TEMP_4
    if(risultato(i,3) >= 18 && risultato(i,3) < 20)
        trasf(i,20) = 1;
    end 
    %TEMP_5
    if(risultato(i,3) >= 20 && risultato(i,3) < 22)
        trasf(i,21) = 1;
    end 
    %TEMP_6
    if(risultato(i,3) >= 22 && risultato(i,3) < 24)
        trasf(i,22) = 1;
    end 
    %TEMP_7
    if(risultato(i,3) >= 24)
        trasf(i,23) = 1;
    end
    %DO_0
    if(risultato(i,4) < 6.5)
        trasf(i,24) = 1;
    end 
    %DO_1
    if(risultato(i,4) >= 6.5 && risultato(i,4) < 7.5)
        trasf(i,25) = 1;
    end 
    %DO_2
    if(risultato(i,4) >= 7.5 && risultato(i,4) < 8.5)
        trasf(i,26) = 1;
    end 
    %DO_3
    if(risultato(i,4) >= 8.5 && risultato(i,4) < 9.5)
        trasf(i,27) = 1;
    end 
    %DO_4
    if(risultato(i,4) >= 9.5 && risultato(i,4) < 10.5)
        trasf(i,28) = 1;
    end 
    %DO_5
    if(risultato(i,4) >= 10.5)
        trasf(i,29) = 1;
    end
    %VOLT_0
    if(risultato(i,5) < 12)
        trasf(i,30) = 1;
    end
    %VOLT_1
    if(risultato(i,5) >= 12  && risultato(i,5) < 14)
        trasf(i,31) = 1;
    end
    %VOLT_2
    if(risultato(i,5) >= 14  && risultato(i,5) < 16)
        trasf(i,32) = 1;
    end 
    %VOLT_3
    if(risultato(i,5) >= 16)
        trasf(i,33) = 1;
    end
end

trasf_t = trasf';

% for i=1:Q
%      idx = find(risultato(:,1) == i);
%    copia = risultato(idx,:);
% 
%   ec_max = max(copia(:,2));
% temp_max = max(copia(:,3));
%   do_max = max(copia(:,4));
% volt_max = max(copia(:,5));
% 
%   ec_min = min(copia(:,2));
% temp_min = min(copia(:,3));
%   do_min = min(copia(:,4));
% volt_min = min(copia(:,5));
% 
% fprintf('Sit.%i:\t ec %f %f \t temp %f %f \t do %f %f \t voltage %f %f \n', i, ec_min, ec_max, temp_min, temp_max, do_min, do_max, volt_min, volt_max);
% end

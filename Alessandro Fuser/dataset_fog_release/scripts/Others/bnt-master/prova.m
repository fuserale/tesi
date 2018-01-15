%Nodo discreto (1): situazione
%Nodo continuo (2): valori continui misurati, nodo multivariato (variabili
%nell'ambiente influenzate dalla situazione)

%HMM con osservazioni gaussiane
%   1 - > 1
%   |     | 
%   v     v
%   2     2

%%O = 139; %numero di variabili del dataset
%%T = 3601; %lunghezza del dataset
ncases = 1; %numero di casi (puoi usarne pi� di uno per il learning
            %ed eventualmente calcolare poi i cluster per l'unico che vuoi
            %testare). Con ncases=1 il learning � su un solo dataset, e il
            %testing � sullo stesso (Ok perch� � unsupervised learning)
%%data = zeros(O,T,ncases); %creo data come matrice di zeri OxTxncases

M = 1; %numero di componenti della mistura di gaussiane con HMM sempre uguale a 1
Q = 2; %il numero di stati della variabile hidden (numero di cluster)

%Caricamento data set. Il file ESP5_h deve essere nella stessa cartella del
%codice e la cartella deve essere aggiunta al path in matlab per poterlo
%eseguire (delimitatore: tabulazione)
%%data5h = dataset('file', 'ESP5_h', 'delimiter', '\t'); 

data5h = readtable('../../dataset/CSV/feature/dynamics/2cl_dynamics_S01R01.csv');
colname = data5h.Properties.VariableNames;
freeze = table2array(data5h(:,140));
time = table2array(data5h(:,1));
data5h = data5h(:,2:139);
[T,O] = size(data5h);
data5hmat = table2array(data5h);
data = zeros(O,T,ncases);
data(:,:,1) = double(data5hmat');

%dal dataset caricato interamente, estraggo solo le parti che mi
%interessano (righe da 1 a 3601 che corrisponde a T, e solo le colonne
%dalla 4 alla 7 in base alle variabili
%%data5h = data5h(1:3601,[4:7]);

%converto il data-set in una matrice
%%data5hmat = double(data5h);

%metto la mia matrice dentro data
%%data(:,:,1) = double(data5hmat');

%probabilit� a priori delle situazioni (random)
prior0 = normalise(rand(Q,1)); 

%togliere commento per dare prior uguale
%for i=1:Q
%prior0(i) = 1/Q;
%end

%probabilit� di passare dallo stato A al tempo i allo stato B al tempo i+1
transmat0 = mk_stochastic(rand(Q,Q));  

% %observation model
%          Sigma0 = repmat(eye(O), [1 1 Q M]); %standard deviation %matrice a covarianza diagonale
%          %Initialize each mean to a random data point
%          indices = randperm(ncases);
%          mu0 = reshape(data(:,indices(1:(Q*M))), [O Q M]); %media
%          mixmat0 = mk_stochastic(rand(Q,M)); %mixmat contiene il peso di ogni componente dato quello stato
        
cov_type = 'full'; 
[mu0, Sigma0] = mixgauss_init(Q*M, reshape(data, [O T*ncases]), cov_type);
mu0 = reshape(mu0, [O Q M]);
Sigma0 = reshape(Sigma0, [O O Q M]);
mixmat0 = mk_stochastic(rand(Q,M));

for i=1:Q
mixmat0(i) = 1/Q;
end

%numero di iterazioni per learning
max_iter = 100;

%i parametri iniziali vengono raffinati attraverso il learning (numero di
%iterazioni massimo = max_iter)
%Finally, let us improve these parameter estimates using EM.
[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', max_iter);

%calcolo la probabilit� del dataset di test
%use the following procedure to compute likelihood:
loglik = mhmm_logprob(data, prior1, transmat1, mu1, Sigma1, mixmat1);

%calcolo la matrice delle probabilit� di emissione (probabilit� che i dati
%siano stati prodotti da un determinato stato/situazione)
%First you need to evaluate B(t,i) = P(y_t | Q_t=i) for all t,i:
%where data(:,:,ex) is OxT where O is the size of the observation vector. 
B = mixgauss_prob(data, mu1, Sigma1, mixmat1);

%il path di viterbi restituisce la sequenza di stati pi� probabile
%Finally, use
[path] = viterbi_path(prior1, transmat1, B);

%matrice complessiva che inserisce il cluster in cui risulta inserita
%ciascuna "riga"
risultato = [path',data'];

%grafico
%con situazione/cluster/path calcolato al primo posto
%le restanti sono le variabili del dataset
x = 1:T;
% for k = 1:9:O
%     figure
%     m = 1;
%     subplot(10,1,m);
%     plot(x, risultato(:,1),  x, freeze);
%     legend('RIS', 'FR');
%     for z = k:k+8
%         subplot(10,1,m+1);
%         plot(risultato(:,z+1)); ylabel(colname(z+1));
%         xlabel('TIME');
%         m = m +1;
%     end
% end
% figure(1)
% subplot(5,1,1);
% plot(1:T, risultato(:,1), 1:T, freeze);ylabel('SIT');
% subplot(5,1,2);
% plot(risultato(:,2));ylabel('ACCX1');
% subplot(5,1,3);
% plot(risultato(:,3));ylabel('ACCY1');
% subplot(5,1,4);
% plot(risultato(:,4));ylabel('ACCZ3');
% subplot(10,1,5);
% plot(risultato(:,5));ylabel('ACCX2');
% subplot(10,1,6);
% plot(risultato(:,6));ylabel('ACCY2');
% subplot(10,1,7);
% plot(risultato(:,7));ylabel('ACCZ2');
% subplot(10,1,8);
% plot(risultato(:,8));ylabel('ACCX3');
% subplot(10,1,9);
% plot(risultato(:,9));ylabel('ACCY3');
% subplot(10,1,10);
% plot(risultato(:,10));ylabel('ACCZ3');
% xlabel('TIME');

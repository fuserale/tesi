function [C]=ga_initialise_centroids(D_emd,k,popsize,numgen,cfrac,mrate)
% D_emd is the input dataset, MxN, where M is number of trials and N is
% number of samples.
% k is number of clusters
% popsize is number of potential solutions in initial population
% numgen is number of generations GA algorithm should run
% cfrac is crossover function
% mrate is mutation rate
%
% Reference:
%
% Maulik U and Bandyopadhyay S. Genetic algorithm-based clustering technique. Pattern Recognition,
% 33:1455–1465, 2000. doi: 10.1016/S0031-3203(99)00137-5.
%
% Holland JH. Genetic algorithms. Scientific American, 267:66–72, 1992.

% initialising
X = D_emd; 
FitnessFunction = @(vec) clustering_fitfunc(vec,X,k);
NoV = size(X,2)*k;
rnums=randi(size(X,1),[popsize,k]);

% generating initial population of solutions
popmat=[];
for pidx=1:k, 
   popmat=horzcat(popmat,X(rnums(:,pidx),:)); 
end

% setting GA parameters
options=gaoptimset('PopulationSize',popsize,'InitialPopulation',popmat,'CrossoverFraction',cfrac,'PopulationType','doubleVector','SelectionFcn',@selectionroulette,'CrossoverFcn',@crossoversinglepoint,'MutationFcn',{@mutationuniform,mrate},'Generations',numgen,'StallGenLimit',Inf,'FitnessScalingFcn',@fitscalingrank,'Display','iter');

% applying GA to find optimal set of cluster centroids
[x,fval] = ga(FitnessFunction,NoV,[],[],[],[],[],[],[],options);

% generating matrix of centroids
s=floor(length(x)/k);
C1=zeros(k,s);

for index=1:1:k,
   C1(index,:)=x(1,(s*(index-1))+1:s*index);   
end

% using C1 to re-assign trials to clusters
X=X-repmat(mean(X,2),1,s);
Xnorm=sqrt(sum(X.^2, 2));
X=X./Xnorm(:,ones(1,s));

D1=distfun(X,C1,'correlation');
[d1,idx1]=min(D1,[],2);

% estimating mean of new clusters in C
for fidx=1:1:k,
    C(fidx,:)= mean(X(find(idx1(:,1)==fidx),:),1);
end

end
% script to execute each step of the cluster analysis pipeline in:
%
% Reference:
% Williams NJ, Nasuto SJ, Saddy, JD. Method for exploratory cluster
% analysis and visualisation of single-trial ERP ensembles. Journal of
% Neuroscience Methods (submitted)

clear;

% installing Cluster toolbox
addpath(genpath(pwd));

% loading dataset
infname='../../dataset/CSV/2cl_S01R01.csv'; % path to input dataset
D=readtable(infname);
fn=fieldnames(D);
D=eval(['D.' fn{3,1}]);

%% EMD-denoising

% finding threshold frequency
maxf=50;                        % max frequency to explore for EMD-denoising
srate=64;                      % sampling rate in Hz
co=10;

% finding cut-off

% DP=emd_cutoff(D,maxf,srate);
% 
% [L]=knee(DP(:,1));
% [jk,indices]=sort(L,'ascend');
% co=indices(2,1);

% applying EMD-denoising

D_emd=emd_den(D,co,srate);
save('emd_den_dataset','D_emd');

%% Determining number of clusters

% Cluster stability

krange=[2:1:20];
prop=0.8;
simreps=200;

S=cluster_stability(D_emd,krange,prop,simreps);
save('stability','S');

% Cluster stability null distribution

stabreps=200;
STABDIST=zeros(stabreps,max(krange));

for repidx=1:stabreps,
    
STABDIST(repidx,:)=cluster_stability_nulldist(D_emd,krange,prop,simreps);

display(repidx);
    
end

save('stability_nulldist','STABDIST');

% number of clusters

mS=mean(S,2)';
pct_thr=95;
STAB_thr=prctile(STABDIST,pct_thr);

k=find(((mS-STAB_thr)>0)==1,1,'first');

%% Clustering

popsize=200; % size of initial population
numgen=50000; % number of generations
cfrac=0.8; % cross-over fraction
mrate=0.01; % mutation rate

% GA-based initialisation of cluster centroids

[C]=ga_initialise_centroids(D_emd,k,popsize,numgen,cfrac,mrate);
save('init_centroids','C');

% k-means clustering

[cidxs,Cf,SUMDf,Df]=kmeans(D_emd,k,'Distance','correlation','Start',C,'Replicates',1);
display(sum(SUMDf));

%% Visualisation

ctemplates=vertcat([0 0 1],[0 1 0],[0 1 1],[1 0 0],[1 0 1],[1 1 0]);
cscaling=vertcat(1,0.8,0.6,0.4,0.2);

colouridx=0;
colours={};

% generating colour codes (for up to 30 clusters)

while colouridx<length(unique(cidxs)),
  
 colouridx=colouridx+1;   
 cscaleidx=floor(colouridx/length(ctemplates))+1;
 ctempidx=rem(colouridx,length(ctemplates));
 colours{1,colouridx}=cscaling(cscaleidx,1)*ctemplates(ctempidx,:);
    
end

sf=2; % scaling factor to relate number of trials to circle area
[PROJ]=clustervis(D_emd,cidxs,sf,colours);

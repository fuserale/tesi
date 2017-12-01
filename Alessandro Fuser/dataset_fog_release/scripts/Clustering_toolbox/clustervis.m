function PROJ=clustervis(D,cidxs,sf,colours)
% D is the input dataset, MxN where M is number of trials, N is number of
% samples
% Mx1 vector of cluster assignments
% sf is scaling factor to relate number of trials in cluster to circle area
% colurs is a 1x k cell array of colours, one for each cluster

% initialisation

nc=length(unique(cidxs));
meanmat=zeros(nc,size(D,2));
freqmat=zeros(nc,1);

% finding cluster means and frequencies

for cnum=1:nc,
    
 meanmat(cnum,:)=mean(D(cidxs(:,1)==cnum,:));
 freqmat(cnum,1)=length(find(cidxs(:,1)==cnum));
    
end

% applying PCA

[PROJ,PC,V]=pca(meanmat',2);
PROJ=PROJ';

% plotting

figure;
xlabel('{\itx}-axis (a.u.)','FontSize',18);
ylabel('{\ity}-axis (a.u.)','FontSize',18);
set(gca,'FontSize',18);
hold on;

for cnum=1:nc,
filledCircle(PROJ(cnum,:),sf*sqrt(freqmat(cnum,1)),10000,colours{1,cnum});
end

end
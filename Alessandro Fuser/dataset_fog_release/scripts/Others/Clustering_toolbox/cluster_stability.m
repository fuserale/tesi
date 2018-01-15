function [S]=cluster_stability(CMAT,krange,prop,simreps)
% CMAT is MxN matrix, where M is number of trials, N is number of samples
% krange is 1xP vector of k-values at which clustering stability is
% estimated
% prop is proportion of trials in dataset used to create subset for
% stability estimation
% simreps is the number of times stability is calculated for a given k
%
% Reference:
%
% Salvador S and Chan P. Determining the number of clusters/segments in hierarchical clustering/
% segmentation algorithms. November 2004.

num_samps=round(prop*size(CMAT,1));
S=zeros(length(krange),simreps);

for k=krange,
    
    for m=1:simreps,
    
    % generating sub-sample indices    
        
    r1=randperm(size(CMAT,1))';
    ss1=r1(1:num_samps,1);
    r2=randperm(size(CMAT,1))';
    ss2=r2(1:num_samps,1);
    
    % performing k-means clustering on sub-samples
    
    [idx1]=kmeans(CMAT(ss1,:),k,'Distance','correlation','Start','sample','Replicates',10);
    [idx2]=kmeans(CMAT(ss2,:),k,'Distance','correlation','Start','sample','Replicates',10);
    
    % find set intersection
    
    [CMN,iss1,iss2]=intersect(ss1,ss2);
    
    D1=idx1(iss1,1);
    D2=idx2(iss2,1);
    
    %% computing similarity between matrices
       
    % partition similarity
    
    S(k,m)=partsim(D1,D2);
       
        
    end
    
    % displaying
    
    display(k);
    
end 

end
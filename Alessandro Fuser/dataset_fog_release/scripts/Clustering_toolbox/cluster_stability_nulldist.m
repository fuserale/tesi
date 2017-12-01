function [STABDIST]=cluster_stability_nulldist(CMAT,krange,prop,simreps)
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

% creating reference distribution

Z=refdist_shape(CMAT);

% cluster stability

S=cluster_stability(Z,krange,prop,simreps);

% estimating sample point in stability distribution
    
STABDIST=mean(S,2)';

end
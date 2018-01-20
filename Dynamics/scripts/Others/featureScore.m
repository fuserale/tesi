function [featIdx, pairs] = featureScore(X, grp, nTop)
% Rank features on discriminative power
%
% featureScore scores and ranks features by their ability to discriminate
% between pairs of clusters or classes. The metric used is the statistic
% from the paired t test with pooled variance. 
%
% Syntax:
% [featIdx, pairs] = featureScore(X, grp, nTop)
%
% X is a nObs-by-nFeat matrix of observations. 
% grp is a grouping variable that denotes class or cluster membership
% nTop is the number of top (highest ranking) features to return
%
% featIdx is a nPairs-by-nTop matrix of feature indices indicating the
% top nTop features for each pair of classes/clusters on each row
% pairs is an nPairs-by-2 matrix where each row indicates the index of the
% two clusters/classes belonging to that pair. 
% 
% Example:
% load fisheriris
% [featIdx, pair] = featureScore(meas, species, 2)
% featIdx =
%      3     4
%      3     4
%      4     3
% pair =
%      1     2
%      1     3
%      2     3

% Copyright 2014 MathWorks, Inc.

uGrp = unique(grp);
nGrp = length(uGrp);
pairs = nchoosek(1:nGrp,2);
nPairs = size(pairs,1);
%featIdx = zeros(nTop, nPairs);

m = nan(nPairs, size(X,2));
s = m;
for i = 1:nPairs
    gid = ismember(grp, uGrp(pairs(i,1)));
    nid = ismember(grp, uGrp(pairs(i,2)));
    Xg = X(gid,:);
    Xn = X(nid,:);
    for j = 1:size(X,2)
        %[~,m(i,j)] = ttest2(Xg(:,j), Xn(:,j));
        [~,~,ci,stat] = ttest2(Xg(:,j), Xn(:,j));
        m(i,j) = abs(stat.tstat);
        s(i,j) = sign(stat.tstat);
    end
end
[~,featIdx] = sort(m, 2, 'descend');
featIdx = featIdx(:,1:nTop);